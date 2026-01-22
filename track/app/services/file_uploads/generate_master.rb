
module FileUploads
  class GenerateMaster
    LEDGER_YAML = 1
    DOLLAR_YEN_TRANSACTION_YAML = 2
    UFJ_YAML = 3

    LEDGER_YAML_FIELDS = "fields"

    DEFAULT_LEDGER_YAML_PATH = "lib/file_record/yamls/ledger.yml"
    DEFAULT_DOLLAR_YEN_TRANSACTION_YAML_PATH = "lib/file_record/yamls/dollar_yen_transaction.yml"
    DEFAULT_UFJ_YAML_PATH = "lib/file_record/yamls/ufj.yml"

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
      elsif @kind == UFJ_YAML
        YAML.load_file("#{Rails.root}/#{DEFAULT_UFJ_YAML_PATH}")
      end
    end
  end
end
