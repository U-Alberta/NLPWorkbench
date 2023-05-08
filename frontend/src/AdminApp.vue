<template>
  <el-container style="height: 100vh">
    <el-header style="height: auto; border-bottom: 1px  solid #2c3e50">
      <el-alert v-if="errMsg" :title="errMsg" type="error" style="margin-top: 20px;"/>
      <el-alert v-if="successMsg" :title="successMsg" type="success" style="margin-top: 20px;"/>
      <el-row>
        <el-col style="text-align: left">
          <h1>NLP Workbench</h1>
        </el-col>
      </el-row>
    </el-header>
    <el-container>
      <el-aside class="aside" :class="{ 'aside-closed': !showSidebar }">
        <el-row justify="end" v-if="showSidebar">
          <el-button size="small" style="margin: 5px 5px 5px 5px" @click="showSidebar=false">
            <el-icon>
              <DArrowLeft />
            </el-icon>
          </el-button>
        </el-row>
        <el-row justify="center" v-else>
          <el-button size="small" style="margin: 5px 5px 5px 5px" @click="showSidebar=true">
            <el-icon>
              <DArrowRight />
            </el-icon>
          </el-button>
        </el-row>
        <el-menu
            :default-active="pane"
            :collapse="!showSidebar"
            :collapse-transition="false"
            @select="onMenuSelect"
        >
          <el-menu-item index="document" @click="openLink('/')">
            <el-icon><Document /></el-icon>
            <span>Document</span>
          </el-menu-item>
          <el-sub-menu index="collection">
            <template #title>
              <el-icon><MessageBox /></el-icon>
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
            <el-icon><Connection /></el-icon>
            <span>Network</span>
          </el-menu-item>
          <el-sub-menu index="system">
            <template #title>
              <el-icon><Setting /></el-icon>
              <span>System</span>
            </template>
            <el-menu-item index="track-jobs" class="subitem" @click="openLink('/flower/')">Track Jobs</el-menu-item>
            <el-menu-item index="api-keys" class="subitem">API Keys</el-menu-item>
          </el-sub-menu>
        </el-menu>
      </el-aside>
      <el-main>
        <BatchModePane v-if="pane==='batch'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg"/>
        <CreateCollectionPane v-else-if="pane==='create-collection'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg"/>
        <ListCollectionsPane v-else-if="pane==='list-collections'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg"/>
        <BrowseCollectionPane v-else-if="pane==='browse-collection'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg"/>
        <PopulateBySearchPane v-else-if="pane==='populate'" @errorMsg="handleErrMsg" @successMsg="handleSuccessMsg"/>
        <div v-else-if="externalPanes.includes(pane)">A new popup window will appear.</div>
        <div v-else>
          This feature hasn't been implemented.
        </div>
      </el-main>
    </el-container>
  </el-container>
</template>

<script>
import BatchModePane from "~/components/BatchModePane.vue";
import CreateCollectionPane from "~/components/CreateCollectionPane.vue";
import ListCollectionsPane from "~/components/ListCollectionsPane.vue";
import PopulateBySearchPane from "~/components/PopulateBySearchPane.vue";
import BrowseCollectionPane from "~/components/BrowseCollectionPane.vue";

export default {
  name: "AdminApp",
  components: [BrowseCollectionPane, PopulateBySearchPane, ListCollectionsPane, CreateCollectionPane, BatchModePane],
  data() {
    return {
      externalPanes: ["document", "batch", "track-jobs", "kibana"],
      showSidebar: true,
      pane: "batch",
      errMsg: "",
      successMsg: "",
    }
  },
  computed: {
  },
  watch: {
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
    openLink: function(link) {
      window.open(link, '_blank').focus()
    },
    onMenuSelect: function(index, indexPath) {
      this.pane = index
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
}

.aside {
  border-right: 1px  solid #2c3e50 !important;
  height: 100% !important;
  width: 200px !important;
}

.aside-closed {
  width: auto !important;
}

.subitem {
  font-size: 12px !important;
  line-height: normal !important;
}
</style>
