### Votingapp

This is a simple API service built for various tests purposes. This was built to test AWS App Runner specifically, but it can be used for other purposes. This application is a scaled down version of (and it's been inspired by) [Yelb](https://github.com/mreferre/yelb/).

The application puts and stores "votes" in an Amazon DynamoDB table. You can vote by just CURLing (or similar) to 4 APIs: 
```
/api/outback
/api/bucadibeppo
/api/ihop
/api/chipotle
```
In addition to vote, you can query the status by CURLing (or similar) the `/api/getvotes` API. Note that there is an ***experimental*** feature in the code to artificially consume more memory/CPU. This is available by hitting the `/api/getheavyvotes` API. The amount of artificial load is determined by two variables (`MEMSTRESSFACTOR` and `CPUSTRESSFACTOR` which default to `1`). You can tweak the amount of load by, for example, setting them to `0.1` if you want less overhead or `10` if you want more overhead. 

If you hit the `/` path of the service a summary of the various APIs available is provided. This path only serves static content and does not test DynamoDB connectivity. 

This is a high level diagram of the application architecture:

![votingapp-architecture](/images/votingapp-architecture.png)

### How to set up the application

This is a classic Python application. To use it with AWS App Runner you can build the image upfront (a `Dockerfile` is provided) and push it to ECR or you can provide the source code directly. If you are deploying the application with AWS App Runner, the root of the repository contains the `apprunner.yaml` file used to configure the required parameters for runtime. The requirement to deploy the application is to create and initialize the DynamoDB table and set the proper permissions. In the [preparation](/preparation) folder there are instructions and code to make this happen. 

The `apprunner.yaml` file has been adapted to enable [X-Ray](https://aws.amazon.com/xray/) integration without the application itself not being instrumented (see [this documentation page](https://docs.aws.amazon.com/apprunner/latest/dg/monitor-xray.html) for more information on how to enable this feature). Remember to enable `Tracing with AWS X-Ray` in the Observability configuration section if you want to activate this integration.   

If you want to familiarize with App Runner and have more step by step instructions on how to deploy applications using either source code directly or existing docker images please check out the [AWS App Runner Workshop](https://www.apprunnerworkshop.com/).  


#### AWS App Runner console deployment

First, please check the [preparation](/preparation) folder in this repository to create the DynamoDB table and the various roles and policies required. Also, if you choose to deploy from source, clone this repo in your GH account. Then move to the AWS App Runner console.

- Click on `Create Service` 
- Repository type: `Source code repository`
- Connect to your GitHub account and select the fork of this repository (use the `main` branch)
- Deployment trigger: `Manual`
- In the build settings select `Use a configuration file`
- Give this service a name 
- In the `Security` section (`Instance role`) select the `votingapp-role` IAM role created by the `prepare.sh` script  

The last step is important because it is what grant this App Runner service access to the DynamoDB table. 

Please note that the `apprunner.yaml` configuration file set the `DDB_AWS_REGION` variable to `us-west-2`. If your DynamoDB table is in another region (and/or if you opted to create a table with a different name) please change/add the variables values accordingly in the file. 

#### AWS App Runner CLI deployment

Similar to the console deployment, please check the [preparation](/preparation) folder in this repository first to create the DynamoDB table and the various roles and policies required. Also, if you choose to deploy from source, clone this repo in your GH account. Be sure you have setup the AWS CLI and proper credentials. 

To deploy this application using the AWS CLI, this repo is provided with a `apprunner_cli_input.json` file. It includes all the configurations you'd otherwise need to manually enter into the console. 

Remember to substitute the `CONNECTION_ARN`, `GH_USER`, `ACCOUNT_ID` and `IAM_ROLE` placeholders in the `apprunner_cli_input.json` file. Once you have done it, you can just run this command: 

```
aws apprunner create-service --cli-input-json file://apprunner_cli_input.json
```

#### Variables

- `DDB_AWS_REGION` this variable is required and needs to be set to the region of the DynamoDB table.
- `DDB_TABLE_NAME` this variable is optional and contains the DynamoDB table name (default: `votingapp-restaurants`)
- `MEMSTRESSFACTOR` and `CPUSTRESSFACTOR` are optional and governs the behaviour of the artificial load (experimental)
- `OTEL_PYTHON_ID_GENERATOR` and `OTEL_PROPAGATORS` are required to enable the X-Ray integration
- `OTEL_PYTHON_DISABLED_INSTRUMENTATIONS` and `OTEL_RESOURCE_ATTRIBUTES` are optional and relates to the X-Ray integration

#### Deploying the application with other services and platforms  

This app has been created to test deployments to AWS App Runner. However, this is a standard Python application you can use in any other context provided you adhere to the architecture and prerequisites. The application comes with its `requirements.txt` file and `Dockerfile`. 

#### Known limitations and to-do

- the `getheavyvotes` API doesn't really work as expected and it's WIP 
- the script should ideally be turned into a CFN template with custom resources to initialize the DDB table
- Even more ideally this could/should be all wrapped (App Runner service + DDB table) with a Copilot artifact
- A simple UI to vote and query the votes is in the works
- the Flask server doesn't have debug enabled. To do so add the following variable: `FLASK_ENV-development` (please note this variable is [incompatible with OpenTelemetry](https://github.com/open-telemetry/opentelemetry-python-contrib/issues/546) so the X-Ray integration won't work until this will get fixed)


#### Licensing

This application is made available under the [MIT license](./LICENSE). The Python prerequisite required to run this application and their licensing are as follows:
```
Flask - BSD License 
Flask-Cors - MIT License
Boto3 - Apache License 2.0
Botocore - Apache License 2.0
Simplejson - Academic Free License (AFL), MIT License (MIT License)
```

