import json
import subprocess
import ollama
import logging
import sys
from datetime import datetime

# ログの設定（ターミナルと agent.log の両方に出力）
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.FileHandler("agent.log", encoding="utf-8"),
        logging.StreamHandler() # ターミナルにも出す
    ]
)

def check_ollama_status() -> bool:
    """Ollama サーバーが起動しているか確認する"""
    try:
        # サーバーとの通信疎通確認（モデル一覧の取得を試みる）
        ollama.list()
        logging.info("✅ Ollama サーバーとの接続を確認しました。")
        return True
    except Exception as e:
        print("❌ [エラー] Ollama サーバーとの通信に失敗しました。")
        print("   `ollama serve` または App が起動しているか確認してください。")
        print(f"   詳細: {e}")
        return False

# 1. 実際にシェルスクリプトを呼び出す関数
def run_rspec_test(spec_path: str) -> str:
    """指定されたパスのRSpecテストを実行する"""
    target_path = spec_path.strip() if spec_path else "spec"

    logging.info(f"🛠 [Tool Call] run_rspec.sh を実行開始 (Target: '{target_path}')")

    try:
        # 先ほど作成した run_rspec.sh を実行
        result = subprocess.run(
            ["./run_rspec.sh", spec_path],
            capture_output=True,
            text=True,
            check=True
        )
        logging.info("✅ [Tool Success] RSpec の実行が成功しました。")
        return result.stdout
    except subprocess.CalledProcessError as e:
        output = e.stdout if e.stdout else str(e)
        logging.warning("⚠️ [Tool Warning] RSpec の実行結果（エラーまたは失敗を含む）を取得しました。")
        return output

# 1-B. RuboCop スクリプトを呼び出す関数（★追加）
def run_rubocop(target_path: str = "") -> str:
    """指定されたパスに対して RuboCop を実行する"""
    path = target_path.strip() if target_path else ""
    logging.info(f"🛠 [Tool Call] run_rubocop.sh を実行開始 (Target: '{path if path else 'all'}')")

    try:
        result = subprocess.run(
            ["./run_rubocop.sh", path],
            capture_output=True,
            text=True,
            check=True
        )
        logging.info("✅ [Tool Success] RuboCop の実行が成功しました。")
        return result.stdout
    except subprocess.CalledProcessError as e:
        output = e.stdout if e.stdout else str(e)
        logging.warning("⚠️ [Tool Warning] RuboCop の実行結果（違反検出等を含む）を取得しました。")
        return output

# 2. Ollamaに渡すツールの定義
tools = [
    {
        "type": "function",
        "function": {
            "name": "run_rspec_test",
            "description": "Dockerコンテナ内でRSpecテストを実行します。",
            "parameters": {
                "spec_path": {
                    "type": "string",
                    "description": "実行するテストのパス。特定ファイルなら 'spec/models/user_spec.rb'、全テスト実行なら 'spec' または空文字を指定。"
                }
            },
            "required": []
        }
    },
    # 追加する RuboCop ツール
    {
        "type": "function",
        "function": {
            "name": "run_rubocop",
            "description": "RuboCopを実行してコードの規約違反や潜在的なバグをチェックします。",
            "parameters": {
                "type": "object",
                "properties": {
                    "target_path": {
                        "type": "string",
                        "description": "チェック対象のファイルやディレクトリのパス (例: app/models/user.rb, 全実行なら空文字を指定。)"
                    }
                },
                "required": []
            }
        }
    }
]

# 3. ツール名と実際の関数をマッピング（★追加）
TOOL_MAP = {
    "run_rspec_test": run_rspec_test,
    "run_rubocop": run_rubocop
}

# 実行関数
def chat_with_agent(user_message: str):
    messages = [
        {
            "role": "system",
            "content": (
                "あなたは優秀なRails開発アシスタントです。"
                "ツール（RSpecやRuboCop）の実行結果（JSON）を受け取ったら、決してJSONをそのまま出力せず、"
                "実行結果（パスした数、失敗した数、エラー内容など）を人間向けにわかりやすく日本語で要約して報告してください。"
            )
        },
        {"role": "user", "content": user_message}
    ]

    # 送信メッセージのログ記録
    logging.info("📤 [Request -> Ollama]")
    logging.info(f"   Messages: {json.dumps(messages, ensure_ascii=False)}")

    # AIにリクエスト送信
    response = ollama.chat(
        model="qwen2.5-coder:3b",
        messages=messages,
        tools=tools
    )

    # 受信内容のログ記録
    logging.info("📥 [Response <- Ollama]")
    logging.info(f"   Raw Message: {response.message}")

    tool_name = None
    args = {}

    # 1. Native の tool_calls で返ってきた場合
    if response.message.tool_calls:
        tool = response.message.tool_calls[0]
        tool_name = tool.function.name
        raw_args = tool.function.arguments
        if isinstance(raw_args, str):
            args = json.loads(raw_args) if raw_args else {}
        else:
            args = raw_args

    # 2. テキスト（content）として JSON が返ってきた場合のフォールバック
    elif response.message.content and "{" in response.message.content:
        try:
            # テキストから JSON 部分を無理やり抽出
            content = response.message.content.strip()
            # ```json ... ``` の囲みがあれば除去
            if "```" in content:
                content = content.split("```")[1].replace("json", "").strip()

            data = json.loads(content)
            # name が TOOL_MAP に含まれていれば採用
            if data.get("name") in TOOL_MAP:
                tool_name = data.get("name")
                args = data.get("arguments", {})
        except Exception:
            pass  # 単なるテキスト回答の場合は無視

    # 該当するツールが存在すれば実行
    if tool_name in TOOL_MAP:
        # パス指定を取得（共通で target_path または spec_path に対応）
        target_path = args.get("target_path") or args.get("spec_path") or ""

        print(f"🤖 [AIの判断] {tool_name} を実行します: Target='{target_path}'")

        # TOOL_MAP から対応する Python 関数を呼び出す
        tool_func = TOOL_MAP[tool_name]
        tool_output = tool_func(target_path)

        # 実行結果を会話履歴に追加して再問い合せ
        messages.append(response.message)
        messages.append({
            "role": "tool",
            "content": tool_output
        })

        final_response = ollama.chat(model="qwen2.5-coder:3b", messages=messages)
        print(f"\n🤖 [AIの回答]\n{final_response.message.content}")
    else:
        # ツール呼び出しを行わない通常の回答
        print(f"\n🤖 [AIの回答]\n{response.message.content}")

# 実行テスト
if __name__ == "__main__":
    # 起動判定を行い、落ちていれば即座に終了
    if not check_ollama_status():
        sys.exit(1)

    print("\n=== Step 1: RuboCop 実行 ===")
    chat_with_agent("すべてのRuboCopを実行して")

    print("=== Step 2: RSpec 実行 ===")
    chat_with_agent("すべてのRSpecテストを実行して")
