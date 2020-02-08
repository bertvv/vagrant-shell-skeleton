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

First of all, fork this project and give it a suitable name. Then, clone it locally.

### Choose default base box

Modify the [Vagrantfile](Vagrantfile) to select your favourite base box. I use a CentOS base box from the [Bento project](https://app.vagrantup.com/bento) at Chef, e.g.  `bento/centos-8`. This is probably the only time you need to edit the `Vagrantfile`.

```Ruby
# Set your default base box here
DEFAULT_BASE_BOX = 'bento/centos-8'
```

### Specify VMs

Next, edit `vagrant-hosts.yml` to specify the VMs in your Vagrant environment. Currently, it contains:

```Yaml
- name: srv001
  ip: 192.168.56.31
```

The `vagrant-hosts.yml` file specifies the nodes that are controlled by Vagrant. You should at least specify a `name:`, other settings (see below) are optional. A host-only adapter is created and the given IP assigned to that interface. Other optional settings that can be specified:

- `ip:` The IP address for the VM.
- `netmask`: By default, the network mask is `255.255.255.0`. If you want another one, it should be specified.
- `mac`: The MAC address to be assigned to the NIC. Several notations are accepted, including "Linux-style" (`00:11:22:33:44:55`) and "Windows-style" (`00-11-22-33-44-55`). The separator characters can be omitted altogether (`001122334455`).
- `intnet`: If set to `true`, the network interface will be attached to an internal network rather than a host-only adapter.
- `auto_config`: If set to `false`, Vagrant will not attempt to configure the network interface.
- `synced_folders`: A list of dicts that specify synced folders. Two keys, `src` (the directory on the host system) and `dest` (the mount point in the guest) are mandatory, another one, `options` is, well, optional. The possible options are the same ones as specified in the [Vagrant documentation on synced folders](http://docs.vagrantup.com/v2/synced-folders/basic_usage.html). One caveat is that the option names should be prefixed with a colon, e.g. `owner:` becomes `:owner:`.
- `box`: Choose another base box instead of the default one specified in Vagrantfile. A box name in the form `USER/BOX` (e.g. `bertvv/centos72`) is fetched from [Atlas](https://atlas.hashicorp.com/boxes/search).
- `box_url`: Download the box from the specified URL instead of from Atlas.

You can add hosts to the environment by adding entries to the `vagrant-hosts.yml` file. An example:

```Yaml
- name: srv001
  ip: 192.168.56.31
- name: srv002
  ip: 192.168.56.32
  box: bertvv/fedora25
- name: srv003
  ip: 192.168.56.33
  synced_folders:
    - src: test
      dest: /tmp/test
    - src: www
      dest: /var/www/html
      options:
        :create: true
        :owner: root
        :group: root
        :mount_options: ['dmode=0755', 'fmode=0644']
```

### Provisioning

For each host you defined, you should add a shell script to the `provisioning/` directory with the same name as the VM, e.g. [srv001.sh](provisioning/srv001.sh). The directory now also contains two other scripts:

- [util.sh](provisioning/util.sh), which contains Bash functions that you can use in your provisioning scripts
- [common.sh](provisioning/common.sh), which contains provisioning tasks that are common to all VMs in your Vagrant environment.

Host-specific provisioning scripts should source both files.

## Contributors

- [Bert Van Vreckem](https://github.com/bertvv/) (maintainer)

## License

Licensed under the 2-clause "Simplified BSD License". See [LICENSE.md](/LICENSE.md) for details.
