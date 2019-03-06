# OpenShift CI/CD Infra

## Rucny Bootstrap

Po naklonovani tohoto repa je nutne mat dostupny OpenShift cluster cez prikaz `oc` s privilegiom cluster admina (vytvaranie novych cluser roli a bindings)

### Vytvorenie roli pre Jenkins service account

```
oc process -f template/jenkins-clusterroles-template.yaml
```

### Vytvorenie Jenkins projektu a serveru

```
oc delete project cicd-jenkins
oc new-app -f templates/jenkins-template.yaml
```


### Spustenie pipeline pre build CI/CD komponent

Nasledne, az je Jenkins POD dostupny je mozne spustit build pipeline pre vytvorenie dalsich infra komponent.

Napriklad:

```
oc start-build bc/pipeline -n cicd-jenkins
```

