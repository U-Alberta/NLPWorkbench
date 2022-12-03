import { createApp } from "vue";
import AdminApp from "./AdminApp.vue";
import { configureApp } from './common'

import "v-network-graph/lib/style.css"
// import all element css, uncommented next line
import "element-plus/dist/index.css";
// or use cdn, uncomment cdn link in `index.html`
import "~/styles/index.scss";


const app = createApp(AdminApp);
configureApp(app);
app.mount("#app");