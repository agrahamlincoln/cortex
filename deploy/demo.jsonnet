(import 'cortex.jsonnet') +
(import 'lib/dynamodb.libsonnet') +
(import 'lib/prometheus.libsonnet') +
(import 'lib/nginx.libsonnet') + 
{
    _config+:: {
        local dynamodb_uri = 'dynamodb://user:pass@' + $._config.dynamodb.name + '.' + $._config.namespace + '.svc.cluster.local:8000',
        #ingester, ruler, querier all need to talk to dynamodb
        ingester+:: {
            extraArgs+: [
                '-dynamodb.url=' + dynamodb_uri,
            ],
        },
        querier+:: {
            extraArgs+: [
                '-dynamodb.url=' + dynamodb_uri,
            ],
        },
        ruler+:: {
            extraArgs+: [
                '-dynamodb.url=' + dynamodb_uri,
            ],
        },
        tableManager+:: {
            extraArgs+: [
                '-dynamodb.url=' + dynamodb_uri,
            ],
        },
        dynamodb+:: {
            name: 'dynamodb',
            image: 'amazon/dynamodb-local:latest',
            labels: { app: $._config.dynamodb.name },
            resources: {},
        },
        nginx+:: {
            name: 'nginx',
            image: 'nginx:1.15',
            labels: { app: $._config.nginx.name },
            configuration: (importstr 'lib/nginx.conf'),
            resources: {},
        },
        prometheusConfig+:: (import 'lib/prometheusConfig.jsonnet'),
        prometheus+:: {
            name: 'prometheus',
            image: 'quay.io/prometheus/prometheus:v2.9.2',
            labels: { app: $._config.prometheus.name },
            configuration: std.manifestYamlDoc($._config.prometheusConfig),
            resources: {},
        },
    },
}
