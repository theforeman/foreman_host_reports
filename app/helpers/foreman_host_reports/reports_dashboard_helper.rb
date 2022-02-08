module ForemanHostReports
  module ReportsDashboardHelper
    def host_reports_searchable_links(name, search, counter, format)
      content_tag :li, :style => "margin-bottom: 5px" do
        content_tag(:span, sanitize('&nbsp;'), :class => 'label', :style => "background-color: #{host_reports_report_color[counter]}") +
          sanitize('&nbsp;') +
          link_to(name, hosts_path(:search => search), :class => "dashboard-links") +
          content_tag(:span, send(counter, format), class: 'pull-right')
      end
    end

    def host_reports_report_color
      {
        :change_hosts => "#4572A7",
        :failure_hosts => "#AA4643",
        :nochange_hosts => "#DB843D",
        :disabled_hosts => "#92A8CD",
      }
    end

    def host_reports_get_overview(options = {})
      format = options[:format]
      state_labels = {
        change_hosts: _('Change'),
        failure_hosts: _('Failure'),
        nochange_hosts: _('No Change'),
        disabled_hosts: _('Disabled alerts'),
      }

      {
        data: state_labels.map { |key, label| [label, send(key, format), host_reports_report_color[key]] },
        searchUrl: hosts_path(search: '~VAL~'),
        searchFilters: state_labels.each_with_object({}) do |(key, filter), filters|
          filters[filter] = send(key, format)
        end,
      }
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

    def host_reports_translated_header(shortname, longname)
      "<th style='width:85px; class='ca'><span class='small' title='' data-original-title='#{longname}'>#{shortname}</span></th>"
    end

    private

    def disabled_hosts(_format = nil)
      Host.authorized(:view_hosts, Host).where(:enabled => false).count
    end

    def change_hosts(format)
      HostReport.authorized(:view_host_reports).my_reports.where("format = ? and change > 0", HostReport.formats[format]).reorder('').group(:host_id).maximum(:id).count
    end

    def nochange_hosts(format)
      HostReport.authorized(:view_host_reports).my_reports.where("format = ? and nochange > 0", HostReport.formats[format]).reorder('').group(:host_id).maximum(:id).count
    end

    def failure_hosts(format)
      HostReport.authorized(:view_host_reports).my_reports.where("format = ? and failure > 0", HostReport.formats[format]).reorder('').group(:host_id).maximum(:id).count
    end
  end
end
