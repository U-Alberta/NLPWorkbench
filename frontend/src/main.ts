import { createApp } from "vue";
import App from "./App.vue";
import "v-network-graph/lib/style.css"
import VNetworkGraph from "v-network-graph";

// import all element css, uncommented next line
import "element-plus/dist/index.css";
// or use cdn, uncomment cdn link in `index.html`
import "~/styles/index.scss";
import { configureApp } from "./common";

// @ts-ignore
const app = createApp(App);
configureApp(app);
app.use(VNetworkGraph);
app.mount("#app");
