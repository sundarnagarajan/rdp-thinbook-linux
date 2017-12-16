## Files to be changed
### /etc/issue
* Change using sed -e 's/ubuntu/cherrytux/gI'

### /etc/issue.net
* Change using sed -e 's/ubuntu/cherrytux/gI'

### /etc/lsb-release
* Change using sed -e 's/ubuntu/cherrytux/gI'

### /etc/dpkg/origins/default
* Symlink - points at /etc/dpkg/origins/ubuntu
* Copy ```/etc/dpkg/origins/ubuntu``` to ```/etc/dpkg/origins/cherrytux```
* Change symlink to point at ```/etc/dpkg/origins/cherrytux```
* We do **NOT** have to change anything in this file since:
    * It refers to the *dpkg origin* - presumably origin of packages
    * Vast majority of packages - except any PPA we add - are from Ubuntu
    * It would be most informative to users to point them at the Ubuntu Vendor and Bugs URL

### /etc/dpkg/origins/ubuntu
* Leave unchanged (owned by package base-files)

### /etc/os-release
Needs a simple script to change (ONLY) the following keys:

* NAME
* PRETTY_NAME
* HOME_URL
* SUPPORT_URL
* BUG_REPORT_URL
* ID

Following keys do not need to be changed:

* UBUNTU_CODENAME=xenial

### /usr/lib/os-release
No changes required. Only ```/etc/os-release``` - which is originally a copy of this file - is used.

### /usr/share/base-files/motd
No changes required

## Analysis of other Ubuntu-derived distributions

| Derivative change | [Bodhi](http://www.bodhilinux.com/) | [Elementary](https://elementary.io/) | [Lite](https://www.linuxliteos.com/) | [Mint](https://linuxmint.com/) | [Peppermint](https://peppermintos.com/) | [Trisquel](https://trisquel.info/) | [Pop! OS](https://system76.com/pop)
| ----------------- | --------- | -------------- | -------- | -------- | ------------ | ---------- | --------- |
| /etc/issue | No | Yes | Yes | Yes | Yes | Yes | Yes |
| /etc/issue.net | No | Yes | No | Yes | Yes | Yes | Yes |
|  |  |  |  |  |  |  |  |
| **/etc/dpkg/origins/default** |  |  |  |  |  |  |  |
| Vendor | No | No | No | No | No | Yes | No |
| Vendor-URL | No | No | No | No | No | Yes | No |
| Bugs | No | No | No | No | No | Yes | No |
| Parent | No | No | No | No | No | Yes | No |
| Symlink to | ubuntu | ubuntu | ubuntu | ubuntu | ubuntu | trisquel | pop-os |
|  |  |  |  |  |  |  |  |
| **/etc/os-release** |  |  |  |  |  |  |  |
| NAME | No | Yes | No | Yes | Yes | Yes | Yes |
| VERSION | No | Yes | No | Yes | Yes | Yes | No |
| ID | No | Yes | No | Yes | Yes | Yes | No |
| ID_LIKE | No | Yes | No | Yes | No | No | No |
| PRETTY_NAME | No | Yes | No | Yes | Yes | Yes | Yes |
| VERSION_ID | No | Yes | No | Yes | Yes | Yes | No |
| HOME_URL | No | Yes | No | Yes | Yes | Yes | Yes |
| SUPPORT_URL | No | Yes | No | Yes | Yes | Yes | Yes |
| BUG_REPORT_URL | No | Yes | No | Yes | Yes | Yes | Yes |
| VERSION_CODENAME | No | Yes | No | Yes | Yes |  | No |
| UBUNTU_CODENAME | No | Yes | No | No | No | Missing | No |
| Symlink to | /usr/lib/os-release | /usr/lib/os-release | /usr/lib/os-release | /usr/lib/os-release | /usr/lib/os-release | No | pop-os/os-release |
|  |  |  |  |  |  |  |  |
| **/etc/lsb-relelase**  |  |  |  |  |  |  |  |
| DISTRIB_RELEASE  | No | Yes | No | Yes | Yes | Yes | No |
| DISTRIB_RELEASE | No | Yes | No | Yes | Yes | Yes | No |
| DISTRIB_CODENAME | No | Yes | No | Yes | No | Yes | No |
| DISTRIB_DESCRIPTION | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Symlink to | No | No | No | No | No | No | /etc/pop-os/lsb-release |
|  |  |  |  |  |  |  |  |
| /usr/share/base-files/motd | No | No | No | No | No | No | No |
|  |  |  |  |  |  |  |  |
| Custom /etc/apt/sources.list | No | No | No |  | No | Yes | No |

