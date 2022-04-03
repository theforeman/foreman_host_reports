module ForemanHostReports
  module ReportsDashboardHelper
    def host_reports_searchable_links(name, count_method, format)
      search = Host.send("#{count_method}_query", format, user_search_query)
      content_tag :li, :style => "margin-bottom: 5px" do
        content_tag(:span, sanitize('&nbsp;'), :class => 'label', :style => "background-color: #{host_reports_report_color[count_method]}") +
          sanitize('&nbsp;') +
          link_to(name, hosts_path(:search => search), :class => "dashboard-links") +
          content_tag(:span, Host.send(count_method, format, user_search_query), class: 'pull-right')
      end
    end

    def host_reports_report_color
      {
        :change_hosts => "#4572A7",
        :failure_hosts => "#AA4643",
        :nochange_hosts => "#DB843D",
        :noevents_hosts => "#89A54E",
        :outofsync_hosts => "#3D96AE",
        :noreports_hosts => "#DB843D",
        :disabled_hosts => "#92A8CD",
      }
    end

    def host_reports_translated_header(shortname, longname)
      "<th style='width:85px; class='ca'><span class='small' title='' data-original-title='#{longname}'>#{shortname}</span></th>"
    end

    def host_reports_get_overview(options = {})
      format = options[:format]
      state_labels = {
        change_hosts: _('Change(s)'),
        failure_hosts: _('Failure(s)'),
        nochange_hosts: _('No change(s)'),
        noevents_hosts: _('No event(s)'),
        outofsync_hosts: _('Out of sync'),
        noreports_hosts: _('No reports'),
        disabled_hosts: _('Disabled alerts'),
      }
      counter = {}
      total = 0
      data = state_labels.map do |key, label|
        counter.store(key, Host.send(key, format, user_search_query))
        total = counter[key] + total
        [label, counter[key], host_reports_report_color[key]]
      end
      failed_percent = total.zero? ? 0 : (counter[:failure_hosts].fdiv(total) * 100).round
      {
        data: data,
        searchUrl: hosts_path(search: '~VAL~'),
        title: { primary: _("#{failed_percent}%"), secondary: state_labels[:failure_hosts] },
        searchFilters: state_labels.each_with_object({}) do |(key, filter), filters|
          filters[filter] = counter[key]
        end,
      }
    end

    def user_search_query
      if @data&.filter&.present?
        "#{@data&.filter} and "
      else
        ""
      end
    end

    def latest_reports
      HostReport.authorized(:view_host_reports).my_reports
                .reorder(:reported_at => :desc)
                .limit(9)
                .preload(:host)
    end

    def latest_reports?
      latest_reports.limit(1).present?
    end

    def total_hosts(format)
      Host.search_for(user_search_query + "report_format = #{format}").reorder("").count
    end
  end
end
