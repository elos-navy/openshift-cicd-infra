# OpenShift CI/CD Infra

## Rucny Bootstrap

Po naklonovani tohoto repa je nutne mat dostupny OpenShift cluster cez prikaz `oc` s privilegiom cluster admina (vytvaranie novych cluser roli a bindings)

### Vytvorenie roli pre Jenkins service account

```
oc process -f templates/jenkins-clusterroles-template.yaml | oc create -f -
```

### Vytvorenie Jenkins projektu a serveru

```
oc delete project cicd-jenkins
oc process -f templates/jenkins-template.yaml | oc create -f -
```

### Spustenie pipeline pre build CI/CD komponent

Nasledne, az je Jenkins POD dostupny je mozne spustit build pipeline pre vytvorenie dalsich infra komponent.

Napriklad z CLI:

```
oc start-build bc/pipeline -n cicd-jenkins
```

