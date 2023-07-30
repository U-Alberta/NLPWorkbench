<template>
  <el-container style="height: 100vh">
    <el-container>
      <el-aside class="aside" :class="{ 'aside-closed': !showSidebar }">
        <el-row justify="end" v-if="showSidebar">
          <el-button size="small" style="margin: 5px 5px 5px 5px" @click="showSidebar = false">
            <el-icon>
              <d-arrow-left />
            </el-icon>
          </el-button>
        </el-row>
        <el-row justify="center" v-else>
          <el-button size="small" style="margin: 5px 5px 5px 5px" @click="openAllMenus">
            <el-icon>
              <d-arrow-right />
            </el-icon>
          </el-button>
        </el-row>
        <el-menu
            :default-openeds="openedMenus"
            :default-active="pane"
            :collapse="!showSidebar"
            :collapse-transition="false"
            @select="onMenuSelect"
        >
          <el-menu-item index="document">
            <el-icon>
              <document />
            </el-icon>
            <span>Document</span>
          </el-menu-item>
          <el-sub-menu index="collection">
            <template #title>
              <el-icon>
                <message-box />
              </el-icon>
              <span>Collection</span>
            </template>
            <el-menu-item index="create-collection" class="subitem">Create Collection</el-menu-item>
            <el-menu-item index="list-collections" class="subitem">List Collections</el-menu-item>
            <el-menu-item index="browse-collection" class="subitem">Browse Collection</el-menu-item>
            <el-menu-item index="populate" class="subitem">Populate Collection</el-menu-item>
            <el-menu-item index="batch" class="subitem">Batch Operation</el-menu-item>
            <el-menu-item index="kibana" class="subitem" @click="openLink('/kibana/')">Open Kibana</el-menu-item>
          </el-sub-menu>
          <el-menu-item index="network">
            <el-icon>
              <connection />
            </el-icon>
            <span>Network</span>
          </el-menu-item>
          <el-sub-menu index="system">
            <template #title>
              <el-icon>
                <setting />
              </el-icon>
              <span>System</span>
            </template>
            <el-menu-item index="track-jobs" class="subitem" @click="openLink('/flower/')">Track Jobs</el-menu-item>
            <el-menu-item index="api-keys" class="subitem">API Keys</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>
      <div class="document-pane" v-if="pane === 'document'">
        <el-header v-if="errMsg || successMsg" style="height: auto; border-bottom: 1px solid #dadce0;">
          <el-alert v-if="errMsg" :title="errMsg" type="error" class="alert"  @close="errMsg = ''"/>
          <el-alert v-if="successMsg" :title="successMsg" type="success" class="alert" @close="successMsg=''" />
        </el-header>
        <!-- load document pane here because we don't want paddings from el-main -->
        <DocumentPane @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg" />
      </div>
      <el-main v-else> <!-- load other panes here -->
        <el-header v-if="errMsg || successMsg" style="height: auto; border-bottom: 1px solid #dadce0;">
          <el-alert v-if="errMsg" :title="errMsg" type="error" class="alert"  @close="errMsg = ''"/>
          <el-alert v-if="successMsg" :title="successMsg" type="success" class="alert" @close="successMsg=''" />
        </el-header>
        <BatchModePane v-if="pane === 'batch'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg" />
        <CreateCollectionPane v-else-if="pane === 'create-collection'" @errorMsg="handleErrMsg"
          @successMsg="handleSuccessMsg" />
        <ListCollectionsPane v-else-if="pane === 'list-collections'" @errorMsg="handleErrMsg"
          @successMsg="handleSuccessMsg" />
        <BrowseCollectionPane v-else-if="pane === 'browse-collection'" @errorMsg="handleErrMsg"
          @successMsg="handleSuccessMsg" />
        <PopulateCollectionPane v-else-if="pane==='populate'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg" @enterKeys="(x)=>pane='api-keys'"/>
        <APIKeysPane v-else-if="pane === 'api-keys'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg"/>
        <div v-else-if="externalPanes.includes(pane)">A new popup window will appear.</div>
        <div v-else>Sorry, this feature is still under development. Please contact administrators if you have questions.</div>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
import {defineComponent} from "vue";
import DocumentPane from "~/components/DocumentPane.vue";
import BatchModePane from "~/components/BatchModePane.vue";
import CreateCollectionPane from "~/components/CreateCollectionPane.vue";
import ListCollectionsPane from "~/components/ListCollectionsPane.vue";
import PopulateCollectionPane from "~/components/PopulateCollectionPane.vue";
import BrowseCollectionPane from "~/components/BrowseCollectionPane.vue";
import APIKeysPane from "~/components/APIKeysPane.vue";
import {Connection, DArrowLeft, DArrowRight, Document, MessageBox, Setting} from "@element-plus/icons-vue";

export default defineComponent({
  name: "MainApp",
  components: {
    Setting,
    Connection,
    MessageBox,
    Document,
    DArrowRight,
    DArrowLeft,
    DocumentPane, BrowseCollectionPane, PopulateCollectionPane, ListCollectionsPane, CreateCollectionPane, BatchModePane, APIKeysPane},
  data() {
    return {
      externalPanes: ["batch", "track-jobs", "kibana"],
      showSidebar: true,
      pane: "document",
      errMsg: "",
      successMsg: "",
      openedMenus: ['document', 'collection', 'network', 'system'],
    }
  },
  methods: {
    handleErrMsg(e, prefix) {
      let errMsg = ""
      if (e.response && e.response.data) {
        errMsg = e.response.data
      } else if (e.message) {
        errMsg = e.message
      } else {
        errMsg = e
      }
      if (prefix) {
        errMsg = `${prefix} ${errMsg}`
      }
      this.errMsg = errMsg
    },
    handleSuccessMsg(msg) {
      this.successMsg = msg
    },
    openLink: function (link) {
      window.open(link, '_blank').focus()
    },
    onMenuSelect: function (index, indexPath) {
      this.pane = index
    },
    openAllMenus() {
      this.openedMenus = ['document', 'collection', 'network', 'system']
      this.showSidebar = true
    }
  },
  mounted() {
    this.openAllMenus()
  }
})
</script>

<style scoped>
.el-menu {
  border-right: none;
}

.aside {
  border-right: 1px solid #00000000;
  height: 100%;
  width: 200px;
  overflow: scroll;
  box-shadow: 0 1px 2px rgba(60,64,67,0.3), 0 2px 6px 2px rgba(60,64,67,0.15)
}

.aside-closed {
  width: auto;
}

.subitem {
  font-size: 12px;
  line-height: normal;
}

.alert {
  margin-top: 15px;
  margin-bottom: 15px;
}

.document-pane {
  display: block;
  flex: 1;
  flex-basis: auto;
  overflow: auto;
  box-sizing: border-box;
}
</style>
