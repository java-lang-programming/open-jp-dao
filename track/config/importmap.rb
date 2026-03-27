# Pin npm packages by running ./bin/importmap

pin "application", preload: true

pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

pin_all_from "app/javascript/views", under: "views"
pin_all_from "app/javascript/shared", under: "shared"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/usecases", under: "usecases"
pin_all_from "app/javascript/repositories", under: "repositories"

pin "flatpickr" # @4.6.13
pin "flatpickr/dist/l10n/ja.js", to: "flatpickr--dist--l10n--ja.js.js" # @4.6.13
pin "ethers", to: "https://esm.sh/ethers@6.13.1"
pin "siwe", to: "https://esm.sh/siwe@2.1.4"