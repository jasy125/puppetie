# windowstasks

Welcome to your new module. A short overview of the generated parts can be found in the PDK documentation at https://puppet.com/pdk/latest/pdk_generating_modules.html .

The README template below provides a starting point with details about what information to include in your README.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with windowstasks](#setup)
    * [What windowstasks affects](#what-windowstasks-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with windowstasks](#beginning-with-windowstasks)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This Task will allow you to pull Computers from AD and install the puppet agent on them from your Puppet Master

## Setup

### What windowstasks affects **OPTIONAL**

* Gets a list of Computers based on serach criteria set, if now set will take all nodes from AD, then check for puppet agent and install if not install already directly from the puppet master which is set in the puppet.conf or the manual value set when running.

### Setup Requirements **OPTIONAL**

* Active Directory User and Computers
* Powershell V3 or later

### Beginning with windowstasks

You can include this Task by first forking the module and then installing with your Puppetfile

```
mod 'puppetie'
  git : 'https://github.com/jasy125/puppetie' ( Update path to your fork )
```

## Usage

To use this task by default will run against then entire Domain unless you set the OU or filters.

#### Required

Username : The Domain User who will have access to install and make changes to systems.

```
username = puppetlocal\Administrator
```

Password : The Domain User Account

#### Optional

pemaster : The Pe Master is optional if the System going to be running the command has the server value set in the puppet.conf as this pulls this value using - puppet config print server

adhost : Will be used in a later revision.

dc : Domain Name such as puppet.local, this should be written as puppet,local. This should be used with an OU

```
puppet.local

dc = puppet,local
```

ou : Organisational Unit such as in your tree puppet -> workstations. This should be used with DC

```
puppet.local 
      - Puppet
          - Workstations
          - Servers

ou = workstations,puppet
ou = servers,puppet
```

filter : If you want to apply a filter to the search in the ou, this can be used with dc and ou but not required.

```
puppet.local 
      - Puppet
          - Workstations
             - Win10-1
             - Win10-2
             - WinXp-1
          - Servers


filter = (Name -like "Win10*")
   Returns Win10-1 Win10-2
       
```

throttle : Number of jobs to run in parallel, by default this is set to two increase to as many as you want to run at the same time.

logging : This is the location of the log file, by default it is created on the C Drive of the system running the task. This can be any location as long as the system running the task can access it.

dryrun : If you want to test the settings before running for real. Default is false.


## Limitations

This needs to be run on an System that has AD Tools or directly on a Domain Controller
Also you will need to set the pemaster value if the host you are going to run this on does not have a puppet.conf file with the server value set or if you are using server_list. You can also point this at any master by using this field.

## Development

Still in Testing Phase

## Release Notes/Contributors/Etc. **Optional**

Contributers 

   - Jasy125
   - MartyEwings
