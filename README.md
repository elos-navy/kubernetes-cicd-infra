# AKS k8s CI/CD ELOS projekt

Skripty a sablony pre vytvorenie CI/CD projektu v Azure AKS


## Prerekvizity

Treba mat nainstalovane azure CLI - prikaz `az` a balicek/prikaz `jq`.
Je nutne sa najskor prihlasit prikazom `az login`.

## Konfiguracia

```
vim config # Nastavenie nazvov rg, clusteru, registry. Pripadne nechat to co tam je, ale cluster by nemal existovat.
```

## Vytvorenie clusteru

```
./k8s_scripts/manage_aks_cluster.sh create_rg
./k8s_scripts/manage_aks_cluster.sh create_cluster
./k8s_scripts/manage_aks_cluster.sh create_acr
./k8s_scripts/manage_aks_cluster.sh setup_credentials
```

## Zmazanie clusteru

```
./k8s_scripts/manage_aks_cluster.sh delete_cluster
./k8s_scripts/manage_aks_cluster.sh delete_acr
./k8s_scripts/manage_aks_cluster.sh delete_rg
```

## Vytvorenie Jenkinsu

```
./bootstrap.sh
```

### Jenkins login

Zistit verejnu adresu jenkins sluzby prikazom:

```
kubectl get svc cicd-jenkins
```

V stlpci `EXTERNAL-IP` je adresa, na ktoru je mozne sa pripojit cez web prehliadac a port 8080.

Meno/heslo do web rozhrania: `admin/admin`

## Zmazanie komponent a jenkinsu

```
./cleanup.sh
```
