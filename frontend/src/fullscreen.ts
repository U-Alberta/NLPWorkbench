import { createApp } from "vue";
import FullscreenApp from "~/FullscreenApp.vue";
import {configureApp} from "~/common";

import "v-network-graph/lib/style.css"
// import all element css, uncommented next line
import "element-plus/dist/index.css";
// or use cdn, uncomment cdn link in `index.html`
import "~/styles/index.scss";
import VNetworkGraph from "v-network-graph";
import ElementPlus from 'element-plus'
import ElTableInfiniteScroll from "el-table-infinite-scroll";
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

// @ts-ignore
const app = createApp(FullscreenApp);
configureApp(app)

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component)
}

app.use(ElementPlus);
app.use(VNetworkGraph);
// @ts-ignore
app.use(ElTableInfiniteScroll);
app.mount("#app");