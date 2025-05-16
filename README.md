# Vagrant environment with shell provisioning

Scaffolding code for a multi-VM Vagrant environment with shell provisioning. It is based on my reusable "[One Vagrantfile to rule them all](https://bertvv.github.io/notes-to-self/2015/10/05/one-vagrantfile-to-rule-them-all/)" (I gave a [lightning talk about this](https://youtu.be/qJ0VNO6z68M) at [Config Management Camp 2016 Ghent](http://cfgmgmtcamp.eu/) - [slides here](http://www.slideshare.net/bertvanvreckem/one-vagrantfile-to-rule-them-all)). Hosts are defined in a simple Yaml format (see below), so setting up a multi-VM environment becomes almost trivial.

For a more advanced Vagrant setup with Ansible provisioning, see this project's big brother, [ansible-skeleton](https://github.com/bertvv/ansible-skeleton).

If you like/use this project, please consider giving it a star. Thanks!

## Getting started

### TL;DR

The short version... After forking and cloning, add VMs in `vagrant-hosts.yml`, e.g.:

```Yaml
# vagrant-hosts.yml
---
- name: srv001
  ip: 192.168.56.31
```

and write a provisioning script with the same name as the VM in the `provisioning/` folder (e.g. `provisioning/srv001.sh`).

### Fork & clone

First of all, fork this project and give it a suitable name. Then, clone it locally. Or, alteratively, download a Zip with the code, extract it, change the directory name, and create a new Git repository.

When booting up the VMs, Vagrant will create a VM group with the same name as the directory where the `Vagrantfile` is located. **Remark** that this will fail when you give a VM the same name as that directory!

### Choose default base box

Modify the [Vagrantfile](Vagrantfile) to select your favourite base box. Currently, it is set to `bento/almalinux-9` from the [Bento project](https://app.vagrantup.com/bento) by Chef. This is probably the only time you need to edit the `Vagrantfile`.

```Ruby
# Set your default base box here
DEFAULT_BASE_BOX = 'bento/almalinux-9'
```

### Specify VMs

Next, edit `vagrant-hosts.yml` to specify the VMs in your Vagrant environment. Currently, it contains:

```Yaml
- name: srv001
  ip: 192.168.56.31
```

The `vagrant-hosts.yml` file specifies the nodes that are controlled by Vagrant. You should at least specify a `name:`, other settings (see below) are optional. A host-only adapter is created and the given IP assigned to that interface. Other optional settings that can be specified:

## Supported settings for `vagrant-hosts.yml`

The table below summarizes all supported settings for specifying VM properties. Unless otherwise noted, all settings are optional.

| Name              | Type         | Default             | Description                               |
| ----------------- | ------------ | ------------------- | ----------------------------------------- |
| `auto_config`     | bool         | `true`              | Disable auto configuration of network     |
| `box_url`         | string       | -                   | URL to the Vagrant box                    |
| `box`             | string       | `bento/almalinux-9` | Vagrant base box                          |
| `cpus`            | int          | -                   | Number of CPUs for the VM                 |
| `disks`           | list of dict | []                  | List of disks to be added to the VM       |
| - `name`          | string       | -                   | Name of the disk                          |
| - `size`          | int          | -                   | Size of the disk in MB                    |
| `forwarded_ports` | list of dict | []                  | NAT adapter port forwarding rules         |
| - `guest`         | int          | -                   | Port on the VM                            |
| - `host`          | int          | -                   | Port on the physical system               |
| `intnet`          | bool         | `false`             | Use internal network instead of host-only |
| `ip`              | string       | DHCP                | IP address for the VM                     |
| `mac`             | string       | -                   | MAC address for the NIC                   |
| `memory`          | int          | -                   | Memory size in MB                         |
| `name`            | string       | -                   | Hostname for the VM (**mandatory**)       |
| `netmask`         | string       | `255.255.255.0`     | Network mask                              |
| `ssh_username`    | string       | -                   | username for the admin user               |
| `ssh_password`    | string       | -                   | password for the admin user               |
| `synced_folders`  | list of dict | []                  | Synced folders (see examples below)       |
| - `src`           | string       | -                   | Source directory on the host system       |
| - `dest`          | string       | -                   | Mount point in the guest                  |
| - `options`       | dict         | -                   | Options for the synced folder             |

### Remarks

- `mac`: Several notations are accepted, including "Linux-style" (`00:11:22:33:44:55`) and "Windows-style" (`00-11-22-33-44-55`). The separator characters can even be omitted altogether (`001122334455`).

- `synced_folders`:
    - `src` (the directory on the host system) and `dest` (the mount point in the guest) are mandatory.
    - `options` is, optional. The possible options are the same ones as specified in the [Vagrant documentation on synced folders](http://docs.vagrantup.com/v2/synced-folders/basic_usage.html). One caveat is that the option names should be prefixed with a colon, e.g. `owner:` becomes `:owner:`.

## Examples

- **Minimal configuration**

    ```yaml
    - name: 'srv001'
    ```

    This will create a VM based on the default base box, attached to the first available host-only adapter. The VM will be assigned with an IP address by the host-only adapter's DHCP server.

- **Static IP address**

    ```yaml
    - name: 'srv001'
      ip: '192.0.2.10'
    ```

    Example with a static IP address in a class C (/24) internal network. If there is currently no host-ony adapter for the given subnet, Vagrant will create one.

- **Custom system settings**

    ```yaml
    - name: 'srv001'
      ip: '192.168.56.10'
      cpus: 4
      memory: 4096
    ```

    This VM will be assigned 4 CPUs and 4GiB of RAM. If you don't specify the memory or number of CPUs, Vagrant will use the values from the base box.

- **Multiple VMs**

    ```yaml
    - name: 'el'
      ip: '192.168.56.10'
      box: 'bento/almalinux-9'

    - name: 'fedora'
      ip: '192.168.56.11'
      box: 'bento/fedora-latest'
    ```

    Two VMs, each based on a different base box, viz. AlmaLinux 9 and the latest Fedora, respectively.

- **Other networking options**


    ```yaml
    - name: 'srv001'
      ip: '172.19.0.10'
      netmask: '255.255.0.0'
      mac: '00:11:22:33:44:55'
      intnet: true
    ```

    Example with most of the available networking options. The VM will be assigned a static IP address within a class B (/16) internal network. The VM will be attached to an *internal* network interface instead of the default host-only. The MAC address is also specified.

- **Extra disks**

    ```yaml
    - name: 'srv001'
      disks:
        - name: 'data'
          size: '5GB'
        - name: 'backup'
          size: '5GB'
    ```

    Example with two extra disks of 5GiB.

- **Port forwarding**

    ```yaml
    - name: 'srv001'
      forwarded_ports:
        - guest: 80
          host: 8080
        - guest: 443
          host: 8443
    ```

    Example with two port forwarding rules. A web server on the VM will be accessible from the physical system via *http://localhost:8080/* (for HTTP) and *https://localhost:8443/* (for HTTPS).

- **Synchronized folders**

    ```yaml
    - name: 'srv001'
      ip: '192.168.56.33'
      synced_folders:
        - src: 'test'
          dest: '/tmp/test'
        - src: 'www'
          dest: '/var/www/html'
          options:
            :create: true
            :owner: 'root'
            :group: 'root'
            :mount_options:
              - 'dmode=0755'
              - 'fmode=0644'
    ```

    Directory `test` (relative to the directory with the `Vagrantfile`) will be synchronized with `/tmp/test` in the VM. The second folder, `www`, will be synchronized with `/var/www/html` in the VM. The options specified in the `options:` section are passed to the Vagrant command line as-is. In this example, the directory will be created if it does not exist, and the owner and group will be set to `root` (instead of the `vagrant` user). The mount options are also specified as a list of strings in the format `'key=value'` (so *not* in YAML format `key: value`!).

## Provisioning

For each host you defined, you can put a shell script in the `provisioning/` directory with the same name as the VM, e.g. [srv001.sh](provisioning/srv001.sh). That script will be executed (with root privileges) when the VM is created, or when you run `vagrant provision` on an existing VM.

Currently, the `provisioning/` directory also contains two other scripts:

- [util.sh](provisioning/util.sh), which contains Bash functions that you can use in your provisioning scripts
- [common.sh](provisioning/common.sh), which contains provisioning tasks that are common to all VMs in your Vagrant environment.

Host-specific provisioning scripts may source both files.

## Contributors

- [Bert Van Vreckem](https://github.com/bertvv/) (maintainer)

## License

Licensed under the 2-clause "Simplified BSD License". See [LICENSE.md](/LICENSE.md) for details.
