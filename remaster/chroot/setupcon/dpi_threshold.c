/*
 * Get MINIMUM DPI of attached monitors
 * I am not a very experienced C programmer, so I compensate by
 * programming VERY defensively
 */

#include <stdio.h> 
#include <stdlib.h> 
#include <string.h>
#include <linux/limits.h>
#include <errno.h>
#include <sys/stat.h>
#include <dirent.h>

// Forward function declarations - only needed for VIM checker
// realpath is in stdlib.h, but seems to need a forward declaration !
extern char *realpath(const char *restrict file_name, char *restrict resolved_name);
// strsep is in string.h - but needs a forward declaration !
extern char *strsep(char **stringp, const char *delim);

// -----------------------------------------------------------------------
// Global varaibles
// -----------------------------------------------------------------------
const int SUCCESS = 0;
const int FAILURE = -1;

// See: https://stackoverflow.com/q/423248
const size_t ERR_MSG_MAX_LEN = 1024;
const size_t MAX_LINE_LEN = 256;

// -----------------------------------------------------------------------
// Macros
// -----------------------------------------------------------------------
#define max(a,b) \
  ({ __typeof__ (a) _a = (a); \
    __typeof__ (b) _b = (b); \
    _a > _b ? _a : _b; })

#define min(a,b) \
  ({ __typeof__ (a) _a = (a); \
     __typeof__ (b) _b = (b); \
     _a < _b ? _a : _b; })

// -----------------------------------------------------------------------
// structs
// -----------------------------------------------------------------------

struct Monitor {
    char path[PATH_MAX];
    char name[NAME_MAX];
    unsigned int h_cm;
    unsigned int v_cm;
    unsigned int h_res;
    unsigned int v_res;
    float h_dpi;
    float v_dpi;
    unsigned int avg_dpi;
    int status;
};


int can_be_int(char const* s) {
    // s can be converted to int (long) IFF:
    //   - s is not empty AND
    //   - After parsing by strtol, rest is empty
    if (0 == strcmp(s, "")) return(FAILURE);
    char *rest;
    strtol(s, &rest, 10);
    if (0 != strcmp("", rest)) return(FAILURE);
    return(SUCCESS);
}

int is_accessible_dir(char const* p) {
    // Returns SUCCESS | FAILURE
    struct stat d;
    char target[PATH_MAX];

    if (NULL == realpath(p, target)) return(FAILURE);
    if (FAILURE == stat(target, &d)) return(FAILURE);
    else {
        if ( (d.st_mode & __S_IFMT) == __S_IFDIR) {
            return(SUCCESS);
        }
        else {
            return(FAILURE);
        }
    }
}

int is_accessible_file(char const* p) {
    // Returns SUCCESS | FAILURE
    struct stat d;
    char target[PATH_MAX];

    if (NULL == realpath(p, target)) return(FAILURE);
    if (FAILURE == stat(target, &d)) return(FAILURE);
    else {
        if ( (d.st_mode & __S_IFMT) == __S_IFREG) return(SUCCESS);
        else return(FAILURE);
    }
}


int endswith(char const *str, char const *suffix) {
    // str: string to be searched
    // suffix: suffix (ending) to search for
    // str and suffix must be NULL-terminated strings
    // Returns SUCCESS | FAILURE
    size_t l1 = strlen(str);
    size_t l2 = strlen(suffix);
    if (0 == l1) return(FAILURE);   // empty str does not end with anything
    if (0 == l2) return(SUCCESS);   // everything ends with empty suffix
    if (l1 < l2) return(FAILURE);
    // l1 >= l2
    if (0 == strcmp(&str[(l1 - l2)], suffix)) return(SUCCESS);
    else return(FAILURE);
}

int startswith(char const *str, char const *prefix) {
    // str: string to be searched
    // prefix: suffix (start) to search for
    // str and suffix must be NULL-terminated strings
    // Returns SUCCESS | FAILURE
    size_t l1 = strlen(str);
    size_t l2 = strlen(prefix);
    if (0 == l1) return(FAILURE);   // empty str does not start with anyting
    if (0 == l2) return(SUCCESS);   // everything starts with empty prefix
    if (l1 < l2) return(FAILURE);
    // l1 >= l2
    if (0 == strncmp(str, prefix, l2)) return(SUCCESS);
    else return(FAILURE);
}

int norm_path(char *dest, char const *p) {
    // dest holds result
    // p is 'normalized' using realpath()
    // if p exists and is accessible (perms etc), output of realpath
    // is indest; otherwise dest contains p unchanged
    // Returns: SUCCESS if p exists and is accessible; FAILURE otherwise
    char target[PATH_MAX];
    if (NULL == realpath(p, target)) {
        strcpy(dest, p);
        return(FAILURE);
    } else {
        strcpy(dest, target);
        return(SUCCESS);
    }
}

int join_path(char * dest, char const *p1, char const *p2) {
    // dest will hold result
    // p1, p2: paths
    // Following behavior of python os.path.join()
    //  - If p2 starts with '/', p1 is IGNORED; dest = p2
    //  - If p1 is not '' and doesn't end with a '/', a trailing '/' is added to p1
    //  - No other changes to p1 or p2

    char local_res[PATH_MAX];
    if (SUCCESS == startswith(p2, "/")) {
        strcpy(dest, p2);
    } else {
    
        strcpy(dest, p1);
        if (0 != strcmp(p1, "") && SUCCESS != endswith(p1, "/") ) {
            strcat(dest, "/");
        }
        strcat(dest, p2);
    }
    if (SUCCESS == norm_path(local_res, dest)) {
        strcpy(dest, local_res);
        return(SUCCESS);
    } else {
        return(FAILURE);
    }
}

size_t read_bytes_from_file(char *dest, char const *p, int n) {
    // dest will hold result
    // p : path to input file
    // n : number of bytes to read
    // Returns number of bytes actually read
    FILE *f = fopen(p, "rb");

    if (f) {
        size_t actually_read = fread(dest, 1, n, f);
        return(actually_read);
    }
    else return(0);
}

size_t read_line(char *dest, char const *p, size_t n) {
    // Reads a SINGLE line from path 'p'
    // dest will hold result
    // p : path to input file
    // n : number of bytes to read
    // Returns number of bytes actually read
    // Returns -1 on error
    
    char *local_dest = (char *)malloc(n);
    if (local_dest == 0) {
        fprintf(stderr, "malloc failed : %s\n", strerror(errno));
        return(-1);
    }
    size_t actually_read = read_bytes_from_file(local_dest, p, n);
    if (actually_read > 0) {
        local_dest[actually_read - 1] = 0;
        local_dest[strcspn(local_dest, "\n")] = 0;
        strcpy(dest, local_dest);
        actually_read = strlen(dest);
    }
    if (local_dest != 0) free(local_dest);
    return(actually_read);
}

void reset_monitor(struct Monitor *m) {
    m->h_cm = 0;
    m->v_cm = 0;
    m->h_res = 0;
    m->v_res = 0;
    m->avg_dpi = 0;
    m->h_dpi = 0.0;
    m->v_dpi = 0.0;
    m->status = FAILURE;
}

void show_monitor(struct Monitor *m) {
    /*
    const char *fmt = "%-16s H_CM: %3dcm V_CM: %3dcm H_RES: %5d V_RES: %5d H_DPI: %5.1f V_DPI: %5.1f AVG_DPI: %3d\n";
    fprintf(stderr, fmt, m->name, m->h_cm, m->v_cm, m->h_res, m->v_res, m->h_dpi, m->v_dpi, m->avg_dpi);
    */
    const char *fmt = "%-16s | H_CM: %3dcm | V_CM: %3dcm | H_RES: %5d | V_RES: %5d | AVG_DPI: %3d\n";
    fprintf(stderr, fmt, m->name, m->h_cm, m->v_cm, m->h_res, m->v_res, m->avg_dpi);
}

int populate_monitor(struct Monitor *m, char *dir_path) {
    char file_path[PATH_MAX];
    size_t actually_read;

    reset_monitor(m);

    char status[32];
    join_path(file_path, dir_path, "status");
    if (FAILURE == is_accessible_file(file_path)) return(FAILURE);
    actually_read = read_line(status, file_path, 10);
    if (actually_read != 10) {
        if (0 != strcmp(status, "connected")) {
            // fprintf(stderr, "DEBUG : %s : status : %s\n", m->name, status);
            return(FAILURE);
        }
    }

    size_t edid_required = 23;
    char edid[edid_required];
    join_path(file_path, dir_path, "edid");
    if (FAILURE == is_accessible_file(file_path)) return(FAILURE);
    actually_read = read_bytes_from_file(edid, file_path, edid_required);
    if (actually_read != edid_required) return(FAILURE);
    if (actually_read == edid_required) {
        m->h_cm = (unsigned int)edid[21];
        m->v_cm = (unsigned int)edid[22];
    }

    char modes[32];
    char *modes_ptr = (char *)&modes;
    char modes_delim = 'x';
    char h_res[32] = "";
    char v_res[32] = "";
    join_path(file_path, dir_path, "modes");
    if (FAILURE == is_accessible_file(file_path)) return(FAILURE);
    actually_read = read_line(modes, file_path, 32);
    if (-1 == actually_read) return(FAILURE);
    strsep((char **)&modes_ptr, (char *)&modes_delim);
    if (NULL == modes_ptr) return(FAILURE);   // 'x' not found
    strcpy(h_res, modes);
    strcpy(v_res, (char *) &(*modes_ptr));
    if (FAILURE == can_be_int(h_res)) return(FAILURE);
    if (FAILURE == can_be_int(v_res)) return(FAILURE);
    m->h_res = atoi(h_res);
    m->v_res = atoi(v_res);

    m->h_dpi = (float)m->h_res * 2.54 / (float)m->h_cm;
    m->v_dpi = (float)m->v_res * 2.54 / (float)m->v_cm;
    m->avg_dpi = (int)( (m->h_dpi + m->v_dpi) / 2.0);

    m->status = SUCCESS;
    return(SUCCESS);
}

int get_min_dpi() {
    // Returns:
    //      -1 : If SYS_DRM_DIR not available
    //       0 : No monitors found
    //      >0 : Min DPI amongst monitors found 
    const char *SYS_DRM_DIR = "/sys/class/drm";
    struct Monitor m;
    DIR *DIR_STRUCT;
    struct dirent *dirent_struct;
    char dir_path[PATH_MAX];
    int min_dpi = 0;

    DIR_STRUCT = opendir(SYS_DRM_DIR);
    if (DIR_STRUCT) {
        while ((dirent_struct = readdir(DIR_STRUCT)) != NULL) {
            if (0 == strcmp(".", dirent_struct->d_name)) continue;
            if (0 == strcmp("..", dirent_struct->d_name)) continue;
            join_path((char *)&dir_path, SYS_DRM_DIR, dirent_struct->d_name);
            if (FAILURE == is_accessible_dir((char *)&dir_path)) continue;

            strcpy(m.path, dir_path);
            strcpy(m.name, dirent_struct->d_name);
            if (FAILURE == populate_monitor(&m, dir_path)) continue;
            if (SUCCESS == m.status) {
                show_monitor(&m);
                if (0 == min_dpi) {
                    min_dpi = m.avg_dpi;
                } else {
                    if (m.avg_dpi < min_dpi) {
                        min_dpi = m.avg_dpi;
                    }
                }
            }
        }
        return(min_dpi);
    } else {
        return(-1);
    }
}

int main(int argc, char **argv) {
    #ifndef __linux__
      // See: https://stackoverflow.com/a/8249232
      // fprintf(stderr, "Only Linux platform supported\n");
      return(1);
    #endif
    // Arbitrary limit - works for this program
    const size_t ARG1_MAX_LEN = 5;
    if (argc < 2) {
        // fprintf(stderr, "DEBUG: Needs an argument\n");
        return(2);
    }
    if (argc > 1) {
        if (ARG1_MAX_LEN < (int)strlen(argv[1])) {
            // fprintf(stderr, "DEBUG: ARG1 too long: %d\n", (int)strlen(argv[1]));
            return(3);
        }      
        if (SUCCESS != can_be_int(argv[1])) {
            // fprintf(stderr, "DEBUG: ARG1 is not a number\n");
            return(4);
        }
    }
    int threshold_dpi = atoi(argv[1]);
    int min_dpi = get_min_dpi();
    if (min_dpi > threshold_dpi) return(0);
    return(5);
}
