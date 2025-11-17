export function setCsvUploadEventListener() {
    const dropArea = document.getElementById('drop-area');
    const fileInput = document.getElementById('file-input');
    const selectedFilesList = document.getElementById('selected-files');
    const uploadButton = document.getElementById('upload-button');
    const uploadStatus = document.getElementById('upload-status');
    const fileError = document.getElementById('file-error'); // エラーメッセージ表示用の要素

    if (!fileInput || !selectedFilesList || !uploadButton || !uploadStatus || !dropArea) {
        console.warn('CSV upload: required element not found. Aborting JS init.');
        return;
    }

    let filesToUpload = [];

    // ファイル選択時の処理
    fileInput.addEventListener('change', (e) => {
        handleFiles(e.target.files);
    });

    // ドラッグ＆ドロップ処理
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, preventDefaults, false);
    });

    function preventDefaults(e) {
        e.preventDefault();
        e.stopPropagation();
    }

    ['dragenter', 'dragover'].forEach(eventName => {
        dropArea.addEventListener(eventName, () => dropArea.classList.add('border-blue-500', 'bg-blue-50'), false);
    });

    ['dragleave', 'drop'].forEach(eventName => {
        dropArea.addEventListener(eventName, () => dropArea.classList.remove('border-blue-500', 'bg-blue-50'), false);
    });

    dropArea.addEventListener('drop', (e) => {
        const dt = e.dataTransfer;
        const files = dt.files;
        handleFiles(files);
    }, false);

    // ファイルの種類をチェックするヘルパー関数
    function isCsvFile(file) {
        const validMimeTypes = [
            'text/csv',
            'application/vnd.ms-excel', // Excelで保存されたCSVの場合
            'text/plain' // 一部の環境ではtext/plainとして扱われる場合がある
        ];
        // MIMEタイプと拡張子の両方でチェック
        return validMimeTypes.includes(file.type) || file.name.toLowerCase().endsWith('.csv');
    }

    // ファイル処理ロジック
    function handleFiles(files) {
        filesToUpload = []; // アップロード対象ファイルをリセット
        selectedFilesList.innerHTML = ''; // リストをクリア
        fileError.classList.add('hidden'); // エラーメッセージを非表示にする

        const selectedFileArray = Array.from(files);
        let hasInvalidFile = false;

        if (selectedFileArray.length === 0) {
            selectedFilesList.innerHTML = '<li class="text-gray-500">ファイルが選択されていません</li>';
            return;
        }

        selectedFileArray.forEach(file => {
            const listItem = document.createElement('li');
            if (isCsvFile(file)) {
                filesToUpload.push(file); // 有効なファイルのみアップロード対象に追加
                listItem.textContent = file.name;
                listItem.classList.add('text-gray-700');
            } else {
                hasInvalidFile = true;
                listItem.textContent = `${file.name} (不正なファイル形式)`;
                listItem.classList.add('text-red-500'); // 不正なファイルは赤色で表示
            }
            selectedFilesList.appendChild(listItem);
        });

        // 不正なファイルが含まれていた場合、エラーメッセージを表示
        if (hasInvalidFile) {
            fileError.classList.remove('hidden');
            uploadButton.disabled = true; // 不正なファイルがある場合はアップロードボタンを無効化
            uploadButton.classList.add('opacity-50', 'cursor-not-allowed');
        } else {
            uploadButton.disabled = false; // 全て有効なファイルならボタンを有効化
            uploadButton.classList.remove('opacity-50', 'cursor-not-allowed');
        }

        if (filesToUpload.length === 0 && selectedFileArray.length > 0) {
            // 選択されたファイルが全て不正だった場合
            selectedFilesList.innerHTML = '<li class="text-gray-500">有効なファイルが選択されていません</li>';
        }

        // ドラッグ＆ドロップで選択したファイルを設定する
        if (filesToUpload.length > 0) {
            // 直接の設定は無理なので、DataTransfer を経由して fileInput.files = dataTransfer.files すればOK
            const dataTransfer = new DataTransfer();
            for (const file of filesToUpload) {
                dataTransfer.items.add(file);
            }
            fileInput.files = dataTransfer.files; // OK!
        }
    }

    // アップロードボタンのクリック処理 (ダミー)
    uploadButton.addEventListener('click', () => {
        if (filesToUpload.length === 0) {
            uploadStatus.textContent = 'アップロードするCSVファイルがありません。';
            uploadStatus.className = 'mt-3 sm:mt-4 text-center text-xs sm:text-sm text-red-600';
            return;
        }

        uploadStatus.textContent = 'CSVファイルをアップロード中...';
        uploadStatus.className = 'mt-3 sm:mt-4 text-center text-xs sm:text-sm text-blue-600';
    });
}

// イベントの登録の呼び出し
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        setCsvUploadEventListener();
    });
} else {
    setCsvUploadEventListener();
}