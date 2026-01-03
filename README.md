# My Wagtail site

First attempt at following the tutorial and then dockerizing for local and K8s usage.

## Branches
- Development - this is where I'll improve the general repo and merge into Master as I see fit.  Github actions also builds off this branch when pushed or updated.  

- branches of Development, used for learning or trying out stuff.  



## Building images for Podman
We will use the build powershell script to build our image locall, need two files:
- IMAGE - the ghcr.io path for the image  
- VERSION - the tag we'll put on the image  

```
build
```

## Running

Wagtail ```DJANGO_SETTINGS_MODULE``` defaults to ```core\settings\dev.py```

### Locally
Just Django ```runserver``` nothing fancy.

### Podman local
docker-compose for the win here

```
podman compose up --build
```

Migrate the DB
```
podman exec -it mywagtailsite-web-1 python manage.py migrate --no-input
```

Create a super user
```
podman exec -it mywagtailsite-web-1  python manage.py createsuperuser
```

To shutdown and delete everything
```
podman compose down --volumes
```

### Kubernetes via Helm
This chart requires the Zalando Postgres operator be installed and working, it's an amazing project out of Europe.  There is a ```database.yaml``` file that builds the postgres database via this operator, super cool.  

The ```_helm``` folder has the helm chart for this.  
- Update the ```values.yaml``` file for your needs:
    - repository, should match ```IMAGE``` file and ```VERSION```  
    - ```volumes:``` section, how big do you want the media folder to be?  Adjust storageClass if necessary  
    - ```postgresql``` section, adjust as needed (size of DB, replicas, etc)

#### Installing helm chart
This chart is specific to Django.  It has a migrate job via Helm that is run on initial install and upgrades.

```
helm install wagtail .\_helm\
```
On initial install, will create the wagtail pod, the DB and a Migrate job pod, which is delayed by ```migrationsSleep``` value.  This runs the ```manage.py migrate --no-input``` command.

Once your migration is done and you have two pods running, you'll need to make an admin user.  Find the name of the wagtail pod and exec a manage.py createsuper user.  Example below:  

```
PS >kubectl k get pods
NAME                       READY   STATUS    RESTARTS   AGE
db-0                       1/1     Running   0          2m59s
wagtail-6567779f6d-c8rdn   1/1     Running   0          2m59s

PS C>kubectl exec -it wagtail-6567779f6d-c8rdn -- python manage.py createsuperuser
Username: admin
Email address:
Password:
Password (again):
This password is too common.
Bypass password validation and create user anyway? [y/N]: Y
Superuser created successfully.
PS C>
```

#### Django migrations
If in the future you need to run migrate, due to a change in schema, you can use the same technique to migrate again.  You should run makemigrations and same them in the image, not dynamically in the pod.

```
PS C>kubectl exec -it wagtail-6567779f6d-c8rdn -- python manage.py migrate
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, home, sessions, taggit, wagtailadmin, wagtailcore, wagtaildocs, wagtailembeds, wagtailforms, wagtailimages, wagtailredirects, wagtailsearch, wagtailusers
Running migrations:
  No migrations to apply.
PS C>
```