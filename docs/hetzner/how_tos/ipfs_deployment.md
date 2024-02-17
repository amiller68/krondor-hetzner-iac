# Hetzner Dedicated Server: Simple IPFS deployment

This walkthrough describes how to set up a Hetzner server to serve content over [IPFS](https://ipfs.tech/). At the end you should have a load-balanced single node IPFS deployment running on your own infrastructure and pointed at by a domain you manage.

This rest of this walkthrough assumes:
- you completed the setup described in [the second walkthrough](./static_nginx_site.md)

## Requirements
You should have the following installed before continuing:
- [Python](https://www.python.org/downloads/)
- [Anisble](https://docs.Anisble.com/Anisble/latest/installation_guide/intro_installation.html)

## Overview
- Goals
- Configuring a firewall
- Initializing IPFS
- Exposing our IPFS services
- Wrap up

## Goals

Before starting, let's define our goals. By reading this walkthrough, I'm assuming you're interested in self hosting content of some kind.
We could do this with the Nginx static site we implemented in the previous walkthough, but let's say you want to reap the benefits
and transparency of content addressing, and opt to serve data over IPFS. Let's make one last assumption that you or your users would also like to be
able to ask your node for pinned content over HTTPS directly, instead of having to do lookups through the DHT.

It sounds like we need to:
- run an IPFS node on our host
- allow our node to communicate with the outside world as a peer
- expose a gateway under our domain to make our node's pinned content publically accessible

Let's also quickly consider how we want to interact with our node. We could SSH into our host, and add content using [Kubo's CLI](https://docs.ipfs.tech/reference/kubo/cli/), but this is cumbersome.
It would be far more convenient to leverage [Kubo's RPC API](https://docs.ipfs.tech/install/command-line/#install-official-binary-distributions). This would allow us to use tools like `curl` to push new content to our node, and also allow us to develop networked applications on top of our deployed node.
This is an exciting prospect -- but we also need to keep in mind that just exposing our API to the outside world is insecure. With all of that that in mind, let's add one last requirement:
- expose an IPFS RPC API to *authorized* users under our domain

## Configuring a firewall

Our previous approach has been to rely on Hetzner's Robot Web UI for managing networked access to our server. That was nice when our deployment was sufficiently simple. However, deploying IPFS is going to require us to open up traffic on specific ports. We could feasibly just add these rules with Hetzner's Robot Web UI, but at this point it would be nice if our configuration started living closer to our scripts -- basically we want to start programmatically adminstering our server's firewall with playbooks, not external UIs. This will make how exactly our hosts are configured more explicitly documented in our respository, and make it easy to enforce that configuration (you just run the relevant script).

In order to setup a proper firewall on your server, run:

```shell
$ ./scripts/admin/firewall.sh 
```

This should handle properly configuring UFW on your server. Take a look at some of the tasks called from the [relevant playbook](../../../ansible/admin/firewall.yaml):

```shell

...

# Allow OpenSSH 
- name: Allow SSH
  ufw:
    rule: allow
    name: OpenSSH

# WebServer Setup

# INBOUND

- name: Allow Inbound Http
  ufw:
    rule: allow
    direction: in
    proto: tcp
    port: '80'

- name: Allow Inbound Https
  ufw:
    rule: allow
    direction: in
    proto: tcp
    port: '443'

- name: Allow Inbound Established Tcp
  ufw:
    rule: allow
    direction: in
    proto: tcp
    port: '32768:65535'


# OUTBOUND

- name: Allow Outbound Tcp
  ufw:
    rule: allow
    direction: out
    proto: tcp

# Ipfs Instance Setup

- name: Allow Tcp over port 4001
  ufw:
    rule: allow
    proto: tcp
    port: '4001'

- name: Allow Tcp over port 5001
  ufw:
    rule: allow
    proto: tcp
    port: '5001'
```

This properly translates our previous WebServer template configuration into a UFW configuration. It also adds a rule to allow our IPFS node to communicate to other peers over TCP through port 4001. You should see something like the following in your console when you run the script:

```shell
PLAY [Setup up UFW firewall for all of our services] *******************************************

TASK [Gathering Facts] *************************************************************************
ok: [65.108.195.167]

TASK [Set logging] *****************************************************************************
ok: [65.108.195.167]

TASK [Log rejected auth] ***********************************************************************
ok: [65.108.195.167]

TASK [Rate limit ssh] **************************************************************************
ok: [65.108.195.167]

TASK [Allow SSH] *******************************************************************************
ok: [65.108.195.167]

TASK [Allow Inbound Http] **********************************************************************
ok: [65.108.195.167]

TASK [Allow Inbound Https] *********************************************************************
ok: [65.108.195.167]

TASK [Allow Inbound Established Tcp] ***********************************************************
ok: [65.108.195.167]

TASK [Allow Outbound Tcp] **********************************************************************
ok: [65.108.195.167]

TASK [Allow Tcp over port 4001] ****************************************************************
ok: [65.108.195.167]

TASK [Enable the firewall] *********************************************************************
ok: [65.108.195.167]

PLAY RECAP *************************************************************************************
65.108.195.167             : ok=11   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

Note: I opted to utilize UFW on my server for implementing my firewall within Ansible. It is also feasible to instead use [Hetzner's Robot API](https://galaxy.ansible.com/ui/repo/published/community/hrobot/?extIdCarryOver=true&sc_cid=701f2000001OH7YAAW), which may be more secure. 

## Initializing IPFS

Now that we have our firewall configured, we can start setting up our IPFS node. We'll start by installing [Kubo](https://docs.ipfs.tech/install/command-line/#system-requirements) on our server under a special user account. This will allow us to run our IPFS node as a service, and also allow us to manage our node's configuration and content using Kubo's CLI.

To do this, simply run:

```shell
$ ./scripts/admin/ipfs.sh 
```

This will do the following:
- create a user account for our IPFS node called `ipfs`. Your admin account will have SSH access to this account.
- install the Kubo binary under the `ipfs` user account and initialize the IPFS node to only serve pinned content over its gateway
- create a systemd service to start our IPFS node on boot and handle restarting it if it crashes
- start our IPFS node on the server

```shell
PLAY [Run Ipfs] ********************************************************************************

TASK [Gathering Facts] *************************************************************************
ok: [65.108.195.167]

TASK [Check if the ipfs user exists] ***********************************************************
changed: [65.108.195.167]

TASK [Debug] ***********************************************************************************
skipping: [65.108.195.167]

TASK [Check if the service user exists] ********************************************************
skipping: [65.108.195.167]

TASK [Create the service user] *****************************************************************
skipping: [65.108.195.167]

TASK [Get the admin user's ssh pub key] ********************************************************
skipping: [65.108.195.167]

TASK [Make sure the service user has a .ssh directory] *****************************************
skipping: [65.108.195.167]

TASK [Make sure the service user has an authorized_keys file] **********************************
skipping: [65.108.195.167]

TASK [Add the admin's ssh pub key] *************************************************************
skipping: [65.108.195.167]

TASK [Check if the /home/ipfs/.ipfs directory exists] ******************************************
ok: [65.108.195.167]

TASK [Install kubo on the service user's home directory] ***************************************
skipping: [65.108.195.167]

TASK [Extract kubo] ****************************************************************************
skipping: [65.108.195.167]

TASK [install kubo] ****************************************************************************
skipping: [65.108.195.167]

TASK [Initialize kubo] *************************************************************************
skipping: [65.108.195.167]

TASK [Configure our gateway to only serve pinned content] **************************************
skipping: [65.108.195.167]

TASK [Configure our API to bind on port 5001] **************************************

skipping: [65.108.195.167]
TASK [Create a systemd service for ipfs] *******************************************************

skipping: [65.108.195.167]

TASK [Reload systemd] **************************************************************************
skipping: [65.108.195.167]

TASK [Enable the ipfs service] *****************************************************************
skipping: [65.108.195.167]

TASK [Start the ipfs service] ******************************************************************
changed: [65.108.195.167]

PLAY RECAP *************************************************************************************
65.108.195.167             : ok=4    changed=2    unreachable=0    failed=0    skipped=15   rescued=0    ignored=0   
```

Great! Let's try interacting with our node through the included Kubo CLI. We can do this by SSHing into our server and running the following:

```shell 
ipfs@krondor-ax41-nvme:~$ ipfs id
{
        "ID": "12D3KooWAwkS1YpZT6kvWJTSBgrPeHiv9KeyMgkXjXhNzC9MvZ4c",
        "PublicKey": "CAESIBC/7PkFrytQHyuOgDzQVsrA3UF6si35LrRgG4T3qcoZ",
        "Addresses": [
                "/ip4/127.0.0.1/tcp/4001/p2p/12D3KooWAwkS1YpZT6kvWJTSBgrPeHiv9KeyMgkXjXhNzC9MvZ4c",
                "/ip4/127.0.0.1/udp/4001/quic-v1/p2p/12D3KooWAwkS1YpZT6kvWJTSBgrPeHiv9KeyMgkXjXhNzC9MvZ4c",
...
```

As we can see, our node is running, discoverable, and listening for updates on port 4001. 
Let's try adding some content and retrieving it. We can do this by running the following:

```shell
ipfs@krondor-ax41-nvme:~$ echo hello > test
ipfs@krondor-ax41-nvme:~$ ipfs add test
added QmZULkCELmmk5XNfCgTnCyFgAVxBRBXyDHGGMVoLFLiXEN test
 6 B / 6 B [===========================================================================] 100.00%ipfs@krondor-ax41-nvme:~$ ipfs cat /ipfs/^C
ipfs@krondor-ax41-nvme:~$ ipfs cat QmZULkCELmmk5XNfCgTnCyFgAVxBRBXyDHGGMVoLFLiXEN
hello
```
Cool! We can use our node to store and retrieve content over IPFS.
But we're not done yet -- we need to expose our node to the outside world in order to fulfill our goals.

## Exposing our IPFS services

So, at this point:
- we should have DNS records pointing to our server's IP address for a domain we own
- our Firewall is configured to allow traffic to our IPFS node and WebServer
- our IPFS node is up and running. It is only accessible from the server it is running on, or as a peer on the IPFS network

We need to:
- expose our IPFS node's gateway to the outside world
- expose our IPFS node's RPC API to authorized users

Luckily for us, Nginx is already configured to serve content over HTTPS. We can use it to proxy requests to our IPFS node's gateway and RPC API. This will allow us to serve pinned content over HTTPS, and also allow us to interact with our node's API over HTTPS.

We can also use Nginx to enforce that only authorized users can interact with our node's API through the use of [HTTP Basic Authentication](https://docs.nginx.com/nginx/admin-guide/security-controls/configuring-http-basic-authentication/).

Let's make some important updates to our Nginx configuration to accomplish this. We'll need to:
- set up a new subdomain for our IPFS services
- create a new server block to proxy requests to our IPFS services
- set up basic authentication for our IPFS services

Important: before continuing, create another A record in your DNS settings for your domain, but this time prefix the subdomain with `ipfs`. For example, if your domain is `krondor.org`, create an A record for `ipfs.krondor.org` and point it to your server's IP address.

Once you've done that, you can simply run:

```shell
$ ./scripts/admin/nginx.sh 
```

one more time to update your Nginx configuration. 
Before looking at the results, let's take a look at some of the tasks called from the [relevant playbook](../../../ansible/admin/nginx/tasks.yml):

```shell
...

- name: Setup a basic auth file for the ipfs subdomain
  import_tasks: ./basic_auth.tasks.yml
  vars:
    basic_auth_user: ipfs

...

- name: Setup server block
  become: yes
  template:
    src: ./ipfs.config.j2
    dest: "/etc/nginx/sites-available/ipfs.{{ domain }}"
- name: Enable the server block
  become: yes
  file:
    src: "/etc/nginx/sites-available/ipfs.{{ domain }}"
    dest: "/etc/nginx/sites-enabled/ipfs.{{ domain }}"
    state: link

- name: Setup domain SSL certificate for ipfs subdomain
  import_tasks: ./ssl.tasks.yml
  vars:
    target_domain: "ipfs.{{ domain }}"
    email: "{{ email }}"

...
```

as well as the relevant [server block](../../../ansible/admin/nginx/templates/ipfs.config.j2):

```shell
limit_req_zone $binary_remote_addr zone=ipfs_api:10m rate=10r/s;

server {
    listen 80;
    listen 443 ssl http2;
    server_name ipfs.{{ domain }};

    ssl_certificate /etc/letsencrypt/live/ipfs.{{ domain }}/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/ipfs.{{ domain }}/privkey.pem; # managed by Certbot

    # Direct all root requests to the gateway
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

server {
    listen 5001 ssl http2;
    server_name ipfs.{{ domain }};

    ssl_certificate /etc/letsencrypt/live/ipfs.{{ domain }}/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/ipfs.{{ domain }}/privkey.pem; # managed by Certbot

    # Direct all API requests to the API
    location / {
        limit_req zone=ipfs_api burst=20 nodelay;

        auth_basic "Restricted";
        auth_basic_user_file /etc/nginx/.htpasswd_ipfs;

        # Ipfs API should be bound to port 5000
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Redirect HTTP to HTTPS
    if ($scheme = http) {
        return 301 https://$server_name$request_uri;
    }
}
```

Essentially:
- we set up SSL much like we did for our WebServer's root domain
- we set up a new server blocks to proxy requests to our IPFS node's gateway and API (which we bound to port 5000). The API server block has a few new features:
  - it implements a reverse proxy to our IPFS node's gateway and API
  - it sets up a rate limit for our IPFS node's API to prevent abuse
  - it sets up basic authentication for our IPFS node's API
Let's take a look at the results:

```shell
PLAY [Init our services on the host] ***********************************************************

TASK [Gathering Facts] *************************************************************************
ok: [65.108.195.167]

TASK [Debug] ***********************************************************************************
ok: [65.108.195.167] => {
    "msg": [
        "Init Nginx Configuration",
        "al@krondor.org",
        "cloud.krondor.org"
    ]
}

TASK [Remove default Nginx configuration] ******************************************************
ok: [65.108.195.167]

TASK [Copy static site files assets] ***********************************************************
ok: [65.108.195.167]

TASK [Setup server block] **********************************************************************
ok: [65.108.195.167]

TASK [Enable the server block] *****************************************************************
ok: [65.108.195.167]

TASK [Debug] ***********************************************************************************
ok: [65.108.195.167] => {
    "msg": [
        "Creating SSL Cert for cloud.krondor.org",
        "Admin Email: al@krondor.org"
    ]
}

TASK [Check if the SSL certificate already exists] *********************************************
ok: [65.108.195.167]

TASK [Generate Let's Encrypt certificate] ******************************************************
skipping: [65.108.195.167]

TASK [Add a cronn job to auto renew certificates if one doesn't already exist] *****************
skipping: [65.108.195.167]

TASK [Check if the /etc/nginx/.htpasswd_ipfs file exists] **************************************
ok: [65.108.195.167]

TASK [Debug] ***********************************************************************************
skipping: [65.108.195.167]

TASK [Create the /etc/nginx/.htpasswd_<basic_auth_user> file] **********************************
skipping: [65.108.195.167]

TASK [Generate a random password openssl] ******************************************************
skipping: [65.108.195.167]

TASK [Save the user's password to a file on the instance] **************************************
skipping: [65.108.195.167]

TASK [Add our (single entry) user to the .htpasswd_<basic_auth_user> file] *********************
skipping: [65.108.195.167]

TASK [Setup server block] **********************************************************************
changed: [65.108.195.167]

TASK [Enable the server block] *****************************************************************
ok: [65.108.195.167]

TASK [Debug] ***********************************************************************************
ok: [65.108.195.167] => {
    "msg": [
        "Creating SSL Cert for ipfs.cloud.krondor.org",
        "Admin Email: al@krondor.org"
    ]
}

TASK [Check if the SSL certificate already exists] *********************************************
ok: [65.108.195.167]

TASK [Generate Let's Encrypt certificate] ******************************************************
skipping: [65.108.195.167]

TASK [Add a cronn job to auto renew certificates if one doesn't already exist] *****************
skipping: [65.108.195.167]

TASK [Restart Nginx] ***************************************************************************
changed: [65.108.195.167]

PLAY RECAP *************************************************************************************
65.108.195.167             : ok=14   changed=2    unreachable=0    failed=0    skipped=9    rescued=0    ignored=0   
```

Great! We should now be able to access our IPFS node's gateway and API over HTTPS. We can test by attempting to access our node's gateway and API using `curl. Let's try and read the test file we added to our node earlier:

```shell
$ curl https://ipfs.krondor.org/QmZULkCELmmk5XNfCgTnCyFgAVxBRBXyDHGGMVoLFLiXEN
hello
```

Success! Let's see if we can add some content to our node using the API:

```shell
$ echo hello > test
$ curl -X POST -F "file=@test" https://ipfs.krondor.org/api/v0/add
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

Oh no! We're getting a 401 error. This is because we haven't provided the correct credentials to access our node's API. We intentionally set up basic authentication to protect our node's API from unauthorized access. We can fix this by providing the correct credentials to our `curl` command. Let's retrieve the credentials from our server and try again. Try running the following:

```shell
$ ./scripts/admin/nginx_auth.sh 
```

You should see something like the following in your console:

```shell
PLAY [List the valid basic auth users for our nginx server] ************************************

TASK [Gathering Facts] *************************************************************************
ok: [65.108.195.167]

TASK [Get the contents of /home/ipfs/.basic_auth.password] *************************************
changed: [65.108.195.167]

TASK [Debug] ***********************************************************************************
ok: [65.108.195.167] => {
    "msg": [
        "ipfs:dont-worry-this-is-a-fake-password-your-password-will-be-different"
    ]
}

PLAY RECAP *************************************************************************************
65.108.195.167             : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

Note: this secret management is a bit of a pain, and not overly secure. It would be better to use a more secure method of managing secrets, like [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html) or [HashiCorp Vault](https://www.vaultproject.io/). For now, we'll just use a simple method of storing our secrets in a file on our server. 

However, now that we have our credentials, we can try adding content to our node again. Try running the following:

```shell
$ curl -X POST -F "file=@test" https://ipfs.krondor.org/api/v0/add -u ipfs:dont-worry-this-is-a-fake-password-your-password-will-be-different
{"Name":"test","Hash":"QmZULkCELmmk5XNfCgTnCyFgAVxBRBXyDHGGMVoLFLiXEN","Size":"14"}```
```

Success!

## Wrap Up

Congratulations! You've successfully set up a Hetzner server to serve content over IPFS. You should now have a load-balanced single node IPFS deployment running on your own infrastructure and pointed at by a domain you manage. You should also be able to interact with your node's API over HTTPS. This is a great foundation for building networked applications on top of IPFS! We'll continue to build on this foundation in the next walkthrough.
