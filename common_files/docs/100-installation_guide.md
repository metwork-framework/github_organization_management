# Installation guide

## Prerequisites

- a `CentOS 6`, `CentOS 7` or `CentOS 8` `x86_64` linux distribution installed (it should also work with correponding RHEL or ScientificLinux distribution)
- (or) a `Fedora 29` or `Fedora 30` `x86_64` linux distribution
- (or) a `mageia 6` or `mageia 7` `x86_64` linux distribution
- (or) an `opensuse/leap:15.0`, `opensuse/leap:15.1`, `opensuse/leap:42.3` `x86_64` linux distribution (it should also work with corresponding SLES distribution)

!!! success "Portable RPMs"
    As we build "reasonably portable" RPM packages, it should work with any RPM based linux distribution
    more recent than `CentOS 6` linux distribution (2011).

!!! tip "We :heart: CentOS"
    As we develop MetWork Framework mainly on `CentOS` linux distributions, this is
    our recommendation if you can choose your OS.

!!! info
    We are working right now on supporting other Linux distributions (debian, ubuntu). Please contact us if you
    are interested in.

- disabled `SELinux`

??? question "How to do that?"
    To disable `SELinux` on a `CentOS` Linux distribution, which is enabled by default, you have to change the file
    `/etc/selinux/config` to set `SELINUX=disabled`, then reboot the system.

??? question "I don't want to disable SELinux!"
    It should work with enabled `SELinux` but we never tested so **tests, comments and help are welcome**.

- internet access to metwork-framework.org (on standard TCP/80 port)

??? question "Offline install?"
    Of course, you can deploy on a computer without internet access but you will have to build your own
    mirror or you will have to install correspondings RPM files manually (not difficult but a little boring).

## Configure the metwork RPM repository

### Check

First check the output of `uname -a |grep x86_64`. If you have nothing, you don't have a `x86_64` distribution installed and you can't install MetWork on it.

### Choose a version

Depending on your needs (stability versus new features), you can choose between several versions :

- released stable versions with a standard [semantic versionning](https://semver.org/) `X.Y.Z` version number *(the more **stable** choice)*, we call it **released stable**
- continuous integration versions of the release branch *(to get future **patch** versions before their release)*, we call it **continuous stable**
- continuous integration of the `master` branch *(to get future **major** and **minor** versions before their release)*, we call it **continuous master**
- continuous integration of the `integration` branch *(the more **bleeding edge** choice)*, we call it **continuous integration**

For each version, you will find the `BaseURL` in the following table:

Version | BaseURL
------- | -------
released stable (example for release 2.1) | http://metwork-framework.org/pub/metwork/releases/rpms/release_2.1/portable/
continuous stable (example for release 2.1) | http://metwork-framework.org/pub/metwork/continuous_integration/rpms/release_2.1/portable/
continuous master | http://metwork-framework.org/pub/metwork/continuous_integration/rpms/master/portable/
continuous integration | http://metwork-framework.org/pub/metwork/continuous_integration/rpms/integration/portable/

??? question "Want to install a released version different from 2.1 ?"
    You have to change the `BaseURL` and replace `/release_2.1/` by `/release_X.Y/`. For example, use
    http://metwork-framework.org/pub/metwork/releases/rpms/release_1.2/portable/
    as `BaseURL` for installing a `1.2.Z` released old version.

### Configure

**For CentOS and Fedora distributions**, to configure the metwork RPM repository,
you just have to create a new `/etc/yum.repos.d/metwork.repo` with the following
content (example for a **released stable** version):

```cfg
[metwork_2_1]
name=MetWork Repository Stable
baseurl=http://metwork-framework.org/pub/metwork/releases/rpms/release_2.1/portable/
gpgcheck=0
enabled=1
metadata_expire=0
```

If you prefer to copy/paste something, you can do that with following root commands
(still for a **released stable**):

```bash
cat >/etc/yum.repos.d/metwork.repo <<EOF
[metwork]
name=MetWork Repository
baseurl=http://metwork-framework.org/pub/metwork/releases/rpms/release_2.1/portable/
gpgcheck=0
enabled=1
metadata_expire=0
EOF
```

??? question "For Mageia distributions?"
    To configure the metwork RPM repository for Mageia distributions, use the following `root` command:
    ```console
    urpmi.addmedia metwork http://metwork-framework.org/pub/metwork/releases/rpms/release_2.1/portable/
    ```

??? question "For SUSE distributions?"
    To configure the metwork RPM repository for SUSE distributions, use the following `root` command:
    ```console
    zypper ar -G http://metwork-framework.org/pub/metwork/releases/rpms/release_2.1/portable/ metwork
    ```

!!! warning
    Previous examples are about stable release. **Be sure
    to change the `baseurl` value if you want a "non stable" MetWork version.**


### Test

**With a CentOS or Fedora distributions**, to test the repository, you can use the command `yum list "metwork*"` (as `root`). You must get several `metwork-...` modules available.

??? question "For Mageia distributions?"
    To test the repository, you can use the command `urpmq --list |grep metwork |uniq` (as `root`). You must get several `metwork-...` modules available.

??? question "For SUSE distributions?"
    To test the repository, you can use the command `zypper pa |grep metwork` (as `root`). You must get several `metwork-...` modules available.

## How to install {{REPO}} metwork module

### Minimal installation

You just have to execute the following command (as `root` user):

=== "CentOS/Fedora"
```console
yum install metwork-{{REPO}}
```

=== "Mageia"
```console
urpmi metwork-{{REPO}}
```

=== "SUSE"
```console
zypper install metwork-{{REPO}}
```

{% if REPO == "mfadmin" %}

!!! warning
    A minimal installation of `mfadmin` module does not make sense as you need
    at least one extra layer to get some real features (see "optional layers")

{% endif %}

{% if REPO == "mfext" %}
### Full installation (all {{REPO}} layers, except [add-ons]({% raw %}{{addons}}{% endraw %}))
{% else %}
### Full installation (all {{REPO}} layers)
{% endif %}

If you prefer a full installation (as `root` user):

=== "CentOS/Fedora"
```console
yum install metwork-{{REPO}}-full
```

=== "Mageia"
```console
urpmi metwork-{{REPO}}-full
```

=== "SUSE"
```console
zypper install metwork-{{REPO}}-full
```


{% if REPO in ("mfserv", "mfadmin") %}
### Optional {{REPO}} layers

You can also add extra (optional) `{{REPO}}` layers.

{% if REPO == "mfserv" %}

=== "CentOS/Fedora"
```console
# To install nodejs support
yum install metwork-mfserv-layer-nodejs
```

=== "Mageia"
```console
# To install nodejs support
urpmi install metwork-mfserv-layer-nodejs
```

=== "SUSE"
```console
# To install nodejs support
zypper install install metwork-mfserv-layer-nodejs
```

{% elif REPO == "mfadmin" %}

=== "CentOS/Fedora"
```console
# To install logs support
yum install metwork-mfadmin-layer-logs

# To install metrics support
yum install metwork-mfadmin-layer-metrics
```

=== "Mageia"
```console
# To install logs support
urpmi metwork-mfadmin-layer-logs

# To install metrics support
urpmi metwork-mfadmin-layer-metrics
```

=== "SUSE"
```console
# To install logs support
zypper install metwork-mfadmin-layer-logs

# To install metrics support
zypper install metwork-mfadmin-layer-metrics
```

{% endif %}

{% endif %}

### Optional mfext layers

You can also add extra (optional) `mfext` layers.

=== "CentOS/Fedora"
```console
# To install some devtools
yum install metwork-mfext-layer-python3_devtools

# To install some (base) scientific libraries
yum install metwork-mfext-layer-scientific_core

# To install java/nodejs binaries
yum install metwork-mfext-layer-nodejs
yum install metwork-mfext-layer-java
```

=== "Mageia"
```console
# To install some devtools
urpmi metwork-mfext-layer-python3_devtools

# To install some (base) scientific libraries
urpmi metwork-mfext-layer-scientific_core

# To install java/nodejs binaries
urpmi metwork-mfext-layer-nodejs
urpmi metwork-mfext-layer-java
```

=== "SUSE"
```console
# To install some devtools
zypper install metwork-mfext-layer-python3_devtools

# To install some (base) scientific libraries
zypper install metwork-mfext-layer-scientific_core

# To install java/nodejs binaries
zypper install metwork-mfext-layer-nodejs
zypper install metwork-mfext-layer-java
```

### Optional mfext layers (from mfext [add-ons]({% raw %}{{addons}}{% endraw %}))

You can also install some optional layers (provided by some mfext [add-ons]({% raw %}{{addons}}{% endraw %}))
in the same way and with the same repository (for official [add-ons]({% raw %}{{addons}}{% endraw %})).

For example (please refer to corresponding add-on documentation)

=== "CentOS/Fedora"
```console
# To install python3 devtools
yum install metwork-mfext-layer-python3_devtools

# To install opinionated VIM with Python3 support
yum install metwork-mfext-layer-python3_vim

# To install all scientific libraries (for Python3)
yum install metwork-mfext-layer-python3_scientific

# To install "machine learning" Python3 libraries
yum install metwork-mfext-layer-python3_ia

# To install "mapserver" stuff for Python3
yum install metwork-mfext-layer-python3_mapserverapi

# [...]
```

=== "Mageia"
```console
# To install python3 devtools
urpmi metwork-mfext-layer-python3_devtools

# To install opinionated VIM with Python3 support
# for CentOS or Fedora (see above note for other distributions)
urpmi metwork-mfext-layer-python3_vim

# To install all scientific libraries (for Python3)
urpmi metwork-mfext-layer-python3_scientific

# To install "machine learning" Python3 libraries
urpmi metwork-mfext-layer-python3_ia

# To install "mapserver" stuff for Python3
urpmi metwork-mfext-layer-python3_mapserverapi

# [...]
```

=== "SUSE"
```console
# To install python3 devtools
zypper install metwork-mfext-layer-python3_devtools

# To install opinionated VIM with Python3 support
# for CentOS or Fedora (see above note for other distributions)
zypper install metwork-mfext-layer-python3_vim

# To install all scientific libraries (for Python3)
zypper install metwork-mfext-layer-python3_scientific

# To install "machine learning" Python3 libraries
zypper install metwork-mfext-layer-python3_ia

# To install "mapserver" stuff for Python3
zypper install metwork-mfext-layer-python3_mapserverapi

# [...]
```

## How to start all metwork modules (after installation)

```console
# As root user
service metwork start
```

!!! note
    If your distribution does not provide `service` command, you can use
    `systemctl start metwork.service` instead or `/etc/rc.d/init.d/metwork start`
    (if you don't have a `systemd` enabled machine or container).

## FAQ

### I don't want to install in `/opt`!

Sorry, but it's our packaging choice in it is coherent with [Linux FHS](https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard). We have no plan to change that.

If you are really not happy with that, you can install MetWork
where you want by recompiling it.

{% if REPO == "mfext" %}
### I don't have enough free space on `/opt`!

Let's say for example you have plenty of free space on `/data` but not in `/opt`, the recommended
way to install `mfext` is to:

- *(stop first all metwork services and apps using metwork (if any))*
- install a minimal `mfext` version (see corresponding chapter)
- move the `/opt/metwork-mfext-X.Y` directory to `/data` (`mv /opt/metwork-mfext-X.Y /data/`) to get a `/data/metwork-mfext-X.Y`
- add a symbolic link in `/opt` to get `/opt/metwork-mfext-X.Y => /data/metwork-mfext-X.Y` (`ln -s /data/metwork-mfext-X.Y /opt/metwork-mfext-X.Y`)
- install extra layers you want

With this procedure, you just need temporarily enough space in `/opt` to install
a minimal version. Then after the move and the symbolic link, this space is migrated to `/data` and all next installations will go in `/data`.

### How to install multiple versions of mfext module on the same machine?

You can install several "major/minor" versions (for example: `2.1.Z` and `1.2.T`)
of the mfext module on the same machine by configuring two package repositories
(one for `release_2.1` and one of `release_1.2`) and by using this special procedure:

=== "CentOS/Fedora"
```console
yum install metwork-mfext-1.2
yum install metwork-mfext-2.1
```

=== "Mageia"
```console
urpmi metwork-mfext-1.2
urpmi metwork-mfext-2.1
```

```console
zypper install metwork-mfext-1.2
zypper install metwork-mfext-2.1
```

!!! note
    You can add this `-X.Y` suffix to every "*mfext*" packages names (including
    optional layers and addons)

!!! warning
    You can't install several "patch" versions (for example: `2.1.1` and `2.1.2`)
    of the mfext module on the same machine. But but this is not usually a
    need because backward compatibility is guaranteed.

With this special procedure, you must not get a `/opt/metwork-mfext` symbolic link
but (only) two `/opt/metwork-mfext-1.2` and `/opt/metwork-mfext-2.1` directories.

Of course, to load the `mfext` profile, you have to point directly to the choosen
suffixed directory. So an app can load and use `mfext 1.2 ` and another one `mfext 2.1`.

### What about other modules?

This nearly works in same way but you have to:

- change the configuration of one version (at least) to changes listening ports to avoid
port collision during module startup
- start services by yourself

!!! warning
    This setup is not well tested but we are interested in. Please contact us
    if you want to share some experiences about that.
{% endif %}
