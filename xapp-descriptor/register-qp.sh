# get appmgr http ip
httpAppmgr=$(kubectl get svc -n ricplt | grep service-ricplt-appmgr-http | awk '{print $3}') 

# for delete the register by curl
curl -X POST "http://${httpAppmgr}:8080/ric/v1/deregister" -H "accept: application/json" -H "Content-Type: application/json" -d '{"appName": "qpdriver", "appInstanceName": "qpdriver"}'

# for delete the registration which is registered after xapp is enabled (qpdriver uses null appInstanceName to register)
curl -X POST "http://${httpAppmgr}:8080/ric/v1/deregister" -H "accept: application/json" -H "Content-Type: application/json" -d '{"appName": "qpdriver", "appInstanceName": ""}'

# get xapp http ip
httpEndpoint=$(kubectl get svc -n ricxapp | grep 8080 | awk '{print $3}')
# get xapp rmr ip
rmrEndpoint=$(kubectl get svc -n ricxapp | grep 4560 | awk '{print $3}')

# do register
curl -X POST "http://${httpAppmgr}:8080/ric/v1/register" -H 'accept: application/json' -H 'Content-Type: application/json' -d '{
  "appName": "qpdriver",
  "appVersion": "1.1.0",
  "configPath": "",
  "appInstanceName": "qpdriver",
  "httpEndpoint": "${httpEndpoint}:8080",
  "rmrEndpoint": "${rmrEndpoint}:4560",
  "config": "{\"name\": \"qpdriver\", \"xapp_name\": \"qpdriver\", \"version\": \"1.1.0\", \"containers\": [{\"name\": \"qpdriver\", \"image\": {\"registry\": \"127.0.0.1:5000\", \"name\": \"o-ran-sc/ric-app-qp-driver\", \"tag\": \"latest\" }}], \"messaging\": {\"ports\": [ {\"name\": \"rmr-data\", \"container\": \"qpdriver\", \"port\": 4560, \"rxMessages\": [\"TS_UE_LIST\"], \"txMessages\": [\"TS_QOE_PRED_REQ\", \"RIC_ALARM\"], \"policies\": [], \"description\": \"rmr receive data port for qpdriver\" }, {\"name\": \"rmr-route\", \"container\": \"qpdriver\", \"port\": 4561, \"description\": \"rmr route port for qpdriver\" } ] }, \"rmr\": {\"protPort\": \"tcp:4560\", \"maxSize\": 2072, \"numWorkers\": 1, \"rxMessages\": [\"TS_UE_LIST\"], \"txMessages\": [\"TS_QOE_PRED_REQ\", \"RIC_ALARM\"], \"policies\": [] }, \"controls\": {\"example_int\": 10000, \"example_str\": \"value\" }}"
}'

# rollback xapp
kubectl rollout restart deployment --namespace ricxapp ricxapp-qpdriver
