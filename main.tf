variable "policy_id" {
  type = string
}

variable "alert_name" {
  type = string
}

# e.g. "FROM TransactionError SELECT count(*) WHERE appName = '${var.service_name}'"
variable "nrql" {
  type = string
}

# "above", "below", "equals"
variable "operator" {
  type = string
}

variable "threshold" {
  description = "しきい値"
  type        = number
}

variable "threshold_duration" {
  description = "しきい値に違反した期間(sec)"
  type        = number
  default     = 300 # 5 min
}

# ref: https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/nrql_alert_condition#nrql
resource "newrelic_nrql_alert_condition" "this" {
  name      = var.alert_name
  policy_id = var.policy_id

  nrql {
    query = var.nrql
    # 取得を開始する時間(分)
    #   デフォルトは3分前から取得開始。短いとデータの未達の確率が上がるため3分が推奨
    evaluation_offset = 3
  }

  # NRQL で取得する時間範囲(秒)
  aggregation_window = 60

  # NRQL の実行結果の扱い
  #  "single_value" 実行結果の値をそのまま扱う
  #  "sum" critical.threshold_duration に応じて実行結果を足す。
  value_function = "single_value"

  critical {
    # 条件
    #   "above", "below", "equals"
    operator = var.operator
    # アラートをトリガーする値
    threshold = var.threshold
    # アラートを発生させる期間(秒)
    #   aggregation_window の倍数である必要がある
    threshold_duration = var.threshold_duration
    # 定義した"期間"に"トリガー"が当てはまった場合の条件
    #   "all": 指定された期間全て
    #   "al_least_once": 一度でもトリガーされたら
    threshold_occurrences = "ALL"
  }

  # アラートが回復しない場合に自動的にアラート状態を終了する時間(秒)
  #   デフォルトは30日(2592000秒)
  #   短すぎると連続して通知が行われてしまう
  violation_time_limit_seconds = 86400 # 24時間
}
