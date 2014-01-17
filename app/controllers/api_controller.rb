require "analytic_utils"
require "javascript_utils"
require "db_utils"
require "date_utils"
require "rollup_methods"

LABEL_MAPPING = {
  "month"      => {sql_select: "#{DBUtils.get_month_by_name('pr.date_created')} month", sql_group_by: 'month', hash_name: 'month'},
  "quarter"    => {sql_select: "#{DBUtils.get_quarter_by_name('pr.date_created')} quarter", sql_group_by: 'quarter', hash_name: 'quarter'},  
  "year"       => {sql_select: "#{DBUtils.get_year('pr.date_created')} year", sql_group_by: 'year', hash_name: 'year'},
  "repository" => {sql_select: 'r.name', sql_group_by: 'r.name', hash_name: 'name'},
  "state"      => {sql_select: "#{DBUtils.get_state_select('pr.state', 'pr.date_merged')} state", sql_group_by: 'state', hash_name: 'state'},
  "company"    => {sql_select: 'c.name', sql_group_by: 'c.name', hash_name: 'name'},
  "user"       => {sql_select: 'u.login', sql_group_by: 'u.login', hash_name: 'login'}
}

DATA_MAPPING = {
  "prs"            => {sql_select: "COUNT(*) num_prs", hash_name: 'num_prs'},
  "avg_days_open"  => {sql_select: "IFNULL(ROUND(AVG(#{DBUtils.get_date_difference('pr.date_closed','pr.date_created')}), 1), 0)  avg_days_open", hash_name: 'avg_days_open'},
  "percent_merged" => {sql_select: "SUM( CASE WHEN pr.date_merged IS NOT NULL THEN 1 ELSE 0 END) /  (COUNT(*) * 1.0) percent_merged", hash_name: 'percent_merged'},
  "commits"        => {sql_select: "COUNT(*) num_commits", hash_name: 'num_commits'}
}

class ApiController < ApplicationController

  def index
    data_request = params[:data_request]
    metric = params[:metric]
    group_by = params[:group_by]
    month = params[:month]
    quarter = params[:quarter]
    year = params[:year]
    start_date = DateUtils.human_slash_date_format_to_db_format(params[:start_date])
    end_date = DateUtils.human_slash_date_format_to_db_format(params[:end_date])
    repo = params[:repo]
    state = params[:state]
    company = params[:company]
    user = params[:user]

    if data_request == 'chart'
      # Get data for the pull request pie chart
      if metric == "commits"
        data = AnalyticUtils.get_commit_analytics(LABEL_MAPPING[group_by][:sql_select],
          DATA_MAPPING[metric][:sql_select],
          LABEL_MAPPING[group_by][:sql_group_by],
          DATA_MAPPING[metric][:hash_name],
          month,
          quarter,
          year,
          start_date,
          end_date,
          repo,
          state,
          company,
          user
        )
      elsif metric == "avg_days_open" || metric == "prs" || metric == "percent_merged"
        data = AnalyticUtils.get_pull_request_analytics(LABEL_MAPPING[group_by][:sql_select],
          DATA_MAPPING[metric][:sql_select],
          LABEL_MAPPING[group_by][:sql_group_by],
          DATA_MAPPING[metric][:hash_name],
          month,
          quarter,
          year,
          start_date,
          end_date,
          repo,
          state,
          company,
          user
        )
      else
        render :text => "Error: Unknown Metric '#{metric}"
      end

      # When this is an avg, we need to roll up with avg
      rollup_method = ROLLUP_METHOD::SUM
      if metric == "avg_days_open" || metric == "percent_merged"
        rollup_method = ROLLUP_METHOD::AVG
      end

      data_top_x = AnalyticUtils.top_x_with_rollup(data,
        LABEL_MAPPING[group_by][:hash_name],
        DATA_MAPPING[metric][:hash_name],
        5,
        'others',
        rollup_method
      )

      prs_data_pie_str = JavascriptUtils.get_pull_request_stats(data_top_x, LABEL_MAPPING[group_by][:hash_name], DATA_MAPPING[metric][:hash_name])
      render :json => prs_data_pie_str
    elsif data_request == 'table'
      # Get data for the pull request table
      if metric == "commits"
        data = AnalyticUtils.get_commit_analytics(LABEL_MAPPING[group_by][:sql_select],
          DATA_MAPPING[metric][:sql_select],
          LABEL_MAPPING[group_by][:sql_group_by],
          DATA_MAPPING[metric][:hash_name],
          month,
          quarter,
          year,
          start_date,
          end_date,
          repo,
          state,
          company,
          user
        )
      elsif metric == "avg_days_open" || metric == "prs" || metric == "percent_merged"
        data = AnalyticUtils.get_pull_request_analytics(LABEL_MAPPING[group_by][:sql_select],
          DATA_MAPPING[metric][:sql_select],
          LABEL_MAPPING[group_by][:sql_group_by],
          DATA_MAPPING[metric][:hash_name],
          month,
          quarter,
          year,
          start_date,
          end_date,
          repo,
          state,
          company,
          user
        )
      else
        render :text => "Error: Unknown Metric '#{metric}"
      end
      @table_handle = "metric_table"
      @table_data = data
      @label_header = LABEL_MAPPING[group_by][:hash_name].titleize
      @data_header = "Contributions"
      @label_index_name = LABEL_MAPPING[group_by][:hash_name]
      @data_index_name = DATA_MAPPING[metric][:hash_name]
      render :partial => "shared/hash_as_table"

    elsif data_request == 'prs_line_graph'
       line_graph = AnalyticUtils.get_timestamps(metric, LABEL_MAPPING[group_by][:sql_select],
                LABEL_MAPPING[group_by][:hash_name],
                month,
                quarter,
                year,
                start_date,
                end_date,
                repo,
                state,
                company,
                user)
       render :json => "{\"response\": #{line_graph}}"
    else
      render :text => "Error: Invalid data_request: #{data_request}"
    end
  end

end