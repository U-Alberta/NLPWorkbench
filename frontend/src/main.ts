import { createApp } from "vue";
import MainApp from "./App.vue";
import {configureApp} from "~/common";

import "v-network-graph/lib/style.css"
// import all element css, uncommented next line
import "element-plus/dist/index.css";
// or use cdn, uncomment cdn link in `index.html`
import "~/styles/index.scss";
import VNetworkGraph from "v-network-graph";
import ElementPlus from 'element-plus'
import ElTableInfiniteScroll from "el-table-infinite-scroll";

// @ts-ignore
const app = createApp(MainApp);
configureApp(app)

app.use(ElementPlus);
app.use(VNetworkGraph);
// @ts-ignore
app.use(ElTableInfiniteScroll);
app.mount("#app");