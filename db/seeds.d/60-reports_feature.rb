f = Feature.where(name: 'Reports').first_or_create
raise "Unable to create host reports proxy feature: #{format_errors f}" if f.nil? || f.errors.any?
