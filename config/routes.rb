Rails.application.routes.draw do
  match '/host_reports' => 'react#index', via: :get

  resources :host_reports, only: %i[] do
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
    end
  end
end
