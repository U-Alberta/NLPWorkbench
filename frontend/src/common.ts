//import ElementPlus from "element-plus";
import { App } from "vue";

export function configureApp(app: App): App {
    app.config.globalProperties.host = import.meta.env.VITE_HOST || "noronha.cs.ualberta.ca"
    app.config.globalProperties.server = import.meta.env.VITE_SERVER || `http://${app.config.globalProperties.host}`
    app.config.globalProperties.api = import.meta.env.VITE_API || "/api"
    return app
}

export function fixAuthor(authorStr: string): string {
    // for some articles the author is "B y F i r s t L a s t a n d F s t L s t"
    // we fix them with "best" effort
    if (/B\sy\s.*/.test(authorStr)) {
        authorStr = authorStr
            .split(/\s+/).join("").slice(2) // remove space and By
            .split("and") // split authors
            .map((author) => author.split(/([A-Z][a-z]*)/).join(" ")) // split name parts
            .join(", ") // join authors
    }
    return authorStr
}