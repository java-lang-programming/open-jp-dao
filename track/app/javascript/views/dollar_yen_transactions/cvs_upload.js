import { setCsvUploadEventListener } from "shared/upload_form";

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
        setCsvUploadEventListener();
    });
} else {
    setCsvUploadEventListener();
}
