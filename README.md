
## Graylog-3

An Ansible playbook to install Graylog 3.1 on a Ubuntu 18.04.3 LTS

#### Pre-requisites:
##### Inventory and Password Variables
Enter the hosts or groups of hosts to target in the `inventory` file in the root directory.

In the Graylog varible file `graylog-3/roles/graylog/vars/main.yml` enter the password secret and root password to use in accessing the Graylog web interface.

#### How to use:
```
$ ansible-playbook playbook.yml -i inventory --private-key=/path/to/private/key
```

##### Web Interface
The Graylog web interface listens on `http://<hostname>:9000/` Log in with: **admin** and the root password.
