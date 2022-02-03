Rails.application.routes.draw do
  resources :hosts do
    member do
      match 'host_reports', to: 'react#index', via: :get
    end
  end

  resources :host_reports, only: %i[index show] do
    collection do
      get 'auto_complete_search'
    end
  end

  namespace :api, defaults: { format: 'json' } do
    scope '(:apiv)', module: :v2, defaults: { apiv: 'v2' }, apiv: /v2/,
      constraints: ApiConstraints.new(version: 2, default: true) do
      resources :host_reports, only: %i[index show create destroy] do
        collection do
          get 'export'
        end
      end
      constraints(id: %r{[^/]+}) do
        resources :hosts, only: [] do
          constraints(host_id: %r{[^/]+}) do
            resources :host_reports, only: %i[index]
          end
        end
      end
    end
  end
end
