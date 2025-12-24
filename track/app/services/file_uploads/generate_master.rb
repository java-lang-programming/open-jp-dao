
module FileUploads
  class GenerateMaster
    LEDGER_YAML = 1
    DOLLAR_YEN_TRANSACTION_YAML = 2
    SUMISHIN_SBI_NYUSHUKINMEISAI = 3

    LEDGER_YAML_FIELDS = "fields"

    DEFAULT_LEDGER_YAML_PATH = "lib/file_record/yamls/ledger.yml"
    DEFAULT_DOLLAR_YEN_TRANSACTION_YAML_PATH = "lib/file_record/yamls/dollar_yen_transaction.yml"
    DEFAULT_SUMISHIN_SBI_NYUSHUKINMEISAI_YAML_PATH = "lib/file_record/yamls/sumishin_sbi_nyushukinmeisai.yml"

    attr_accessor :kind

    # @param [Integer] kind
    def initialize(kind:)
      @kind = kind
    end

    def master
      if @kind == LEDGER_YAML
        YAML.load_file("#{Rails.root}/#{DEFAULT_LEDGER_YAML_PATH}")
      elsif @kind == DOLLAR_YEN_TRANSACTION_YAML
        YAML.load_file("#{Rails.root}/#{DEFAULT_DOLLAR_YEN_TRANSACTION_YAML_PATH}")
      elsif @kind == SUMISHIN_SBI_NYUSHUKINMEISAI
        YAML.load_file("#{Rails.root}/#{DEFAULT_SUMISHIN_SBI_NYUSHUKINMEISAI_YAML_PATH}")
      end
    end
  end
end
