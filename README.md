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

Briefly tell users why they might want to use your module. Explain what your module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module is what they want.

## Setup

### What windowstasks affects **OPTIONAL**

If it's obvious what your module touches, you can skip this section. For example, folks can probably figure out that your mysql_instance module affects their MySQL instances.

If there's more that they should know about, though, this is the place to mention:

* Files, packages, services, or operations that the module will alter, impact, or execute.
* Dependencies that your module automatically installs.
* Warnings or other important notices.

### Setup Requirements **OPTIONAL**

Requires 

Active Directory User and Computers
Powershell V3 or later

### Beginning with windowstasks

You can include this Task by first forking the module and then installing with your Puppetfile

```
mod 'puppetie'
  git : 'https://github.com/jasy125/puppetie' ( Update to path to your fork )
```

## Usage

To use this task by default will run against then entire Domain unless you set the OU and DC.

Required

Username : The Domain User who will have access to install and make changes to systems.
Password : The Domain User Account

Optional

pemaster : The Pe Master is optional if the System going to be running the command has the server value set in the puppet.conf as this pulls this value using - puppet config print server

adhost : Will be used in a later revision.

dc : Domain Name such as puppet.com, this should be written as puppet,com. This should be used with an OU

```
puppet.com

dc = puppet,com
```

ou : Organisational Unit such as in your tree puppet -> workstations. This should be used with DC

```
puppet.com 
      - Puppet
          - Workstations
          - Servers

ou = workstations,puppet
ou = servers,puppet
```

filter : If you want to apply a filter to the search in the ou, this can be used with dc and ou but not required.

```
puppet.com 
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

dryrun : If you want to test the settings before running for real. Default is false ( Still work in progress for additional logging )

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```



## Limitations

This needs to be run on an System that has Active Directory Users and Computers or directly on a Domain Controller
Also you will need to set the pemaster value if the host you are going to run this on does not have a puppet.conf file with the server value set. Also you can point this at any master by using this field.

## Development

Please fork this repo and not run directly from it as changes may happen.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
