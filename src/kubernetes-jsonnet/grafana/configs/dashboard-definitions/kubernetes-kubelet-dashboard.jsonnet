local grafana = import "grafonnet/grafana.libsonnet";
local dashboard = grafana.dashboard;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local row = grafana.row;
local template = grafana.template;
local promgrafonnet = import "promgrafonnet/promgrafonnet.libsonnet";
local numbersinglestat = promgrafonnet.numbersinglestat;

local podsCount = numbersinglestat.new(
        "Count",
        "sum(kubelet_running_pod_count{instance=~\"$instance\"})",
    )
    .withSpanSize(2)
    .withSparkline();

local podsGraph = graphPanel.new(
        "Count",
        datasource="prometheus",
        span=10,
        min=0,
        stack=true,
    )
    .addTarget(prometheus.target(
        "kubelet_running_pod_count{instance=~\"$instance\"}",
        legendFormat="{{ instance }}",
    ));

local podRow = row.new(title="Pods", showTitle=true, titleSize="h4")
    .addPanel(podsCount)
    .addPanel(podsGraph);

local containersCount = numbersinglestat.new(
        "Count",
        "sum(kubelet_running_container_count{instance=~\"$instance\"})",
    )
    .withSpanSize(2)
    .withSparkline();


local containersGraph = graphPanel.new(
        "Count",
        datasource="prometheus",
        span=10,
        min=0,
        stack=true,
    )
    .addTarget(prometheus.target(
        "kubelet_running_container_count{instance=~\"$instance\"}",
        legendFormat="{{ instance }}",
    ));

local containerRow = row.new(title="Containers", showTitle=true, titleSize="h4")
    .addPanel(containersCount)
    .addPanel(containersGraph);

local operationsGraph = graphPanel.new(
        "Operations",
        description="Rate of Kubelet Operations in 5min",
        datasource="prometheus",
        min=0,
    )
    .addTarget(prometheus.target(
        "sum(rate(kubelet_runtime_operations{instance=~\"$instance\"}[5m])) by (instance)",
        legendFormat="{{ instance }}",
    ));

local kubeletRow = row.new(title="Kubelet", showTitle=true, titleSize="h4")
    .addPanel(operationsGraph);

dashboard.new("Kubelet", time_from="now-1h")
    .addTemplate(
        template.new(
            "instance",
            "prometheus",
            "label_values(kubelet_running_pod_count,instance)",
            includeAll=true,
            refresh="time",
        )
    )
    .addRow(podRow)
    .addRow(containerRow)
    .addRow(kubeletRow)
