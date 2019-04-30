# AKS k8s CI/CD ELOS projekt

Skripty a sablony pre vytvorenie CI/CD projektu v Azure AKS

## Vytvorenie clusteru

```
vim ./k8s_scripts/manage_aks_cluster.sh # Nastavenie nazvu rg a clusteru, pripadne nechat to co tam je, ale cluster by nemal existovat.

./k8s_scripts/manage_aks_cluster.sh create_rg
./k8s_scripts/manage_aks_cluster.sh create_cluster
./k8s_scripts/manage_aks_cluster.sh setup_credentials
```

## Zmazanie clusteru

```
./k8s_scripts/manage_aks_cluster.sh delete_cluster
```

## Vytvorenie Jenkinsu

```
./bootstrap.sh
```

### Jenkins login

admin/xxxxxx

## Zmazanie komponent a jenkinsu

```
./cleanup.sh
```
