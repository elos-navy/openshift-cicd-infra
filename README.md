# OpenShift CI/CD Infra

## Bootstrap

Po naklonovani tohoto repa a dostupnom OpenShiftu cez `oc` prikaz:

```
oc new-app -f templates/jenkins-template.yaml
```

Nasledne je mozne spustit build pipeline pre vytvorenie dalsich infra komponent.

Napriklad:

```
oc start-build bc/pipeline
```
