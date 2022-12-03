<template>
  <el-container style="height: 100vh">
  <el-header style="height: auto; padding-bottom:10px; border-bottom: 1px  solid #2c3e50">
    <el-alert v-if="errMsg" :title="errMsg" type="error" style="margin-top: 20px;"/>
    <el-row style="align-items: center;">
      <el-col :span="12" style="text-align: left">
        <h1>NLP Workbench</h1>
      </el-col>
      <el-col :span="12" style="justify-content: right; column-gap:5px; display: flex">
        <el-select v-model="collection" class="m-2" placeholder="Select" size="small">
          <el-option
              v-for="item in availableCollections"
              :key="item"
              :label="item"
              :value="item"
          />
        </el-select>
        <el-tooltip
            class="box-item"
            effect="dark"
            content="refresh the collection list"
            placement="bottom">
          <el-button circle size="small" @click="loadCollections">
            <el-icon>
              <Refresh />
            </el-icon>
          </el-button>
        </el-tooltip>
      </el-col>
    </el-row>
  </el-header>
  <el-container style="height: 100%;">
    <el-main>
      <div v-if="availableCollections.length > 0 || collection !== null">
        <el-row style="margin-bottom: 20px" :gutter="10">
          <el-col :span="10" >
            <el-input v-model="newsIdInput" placeholder="News article ID / URL"/>
          </el-col>
          <el-col :span="10" style="display: flex;justify-items: start">
            <el-button @click="loadNews" type="primary" plain>Load News</el-button>
            <el-button @click="loadNews('random')" plain>☘️ Feelin' Lucky</el-button>
          </el-col>
          <el-col :span="4">
            <el-button style="justify-self: end" plain @click="openLink('/admin/')"><el-icon><Operation />️</el-icon>&nbsp;  Admin</el-button>
          </el-col>
        </el-row>
        <el-empty v-if="!newsInfo && !newsInfoLoading" description="No news article selected."></el-empty>
        <div v-loading="newsInfoLoading">
          <el-descriptions v-if="newsInfo" title="Article Info">
            <el-descriptions-item label="Title">{{ newsInfo.title }}</el-descriptions-item>
            <el-descriptions-item label="Author">{{ newsInfo.author }}</el-descriptions-item>
            <el-descriptions-item label="Published">{{newsInfo.published}}</el-descriptions-item>
            <el-descriptions-item label="URL">{{newsInfo.url}}</el-descriptions-item>
          </el-descriptions>
          <el-collapse v-if="newsInfo">
            <el-collapse-item title="Content">
              <div style="text-align: left">{{newsInfo.content}}</div>
            </el-collapse-item>
          </el-collapse>
        </div>
        <el-tabs v-model="activeTab" v-if="newsInfo" type="border-card" style="margin-top: 40px;">
          <el-tab-pane label="Entity Recognition" name="ner">
            <NERPane :newsId="newsId" :newsIdInput="newsIdInput" :collection="collection" @errorMsg="handleErrMsg" />
          </el-tab-pane>
          <el-tab-pane label="Semantic Parsing" name="amr">
            <SemanticParsingPane :newsId="newsId" :newsIdInput="newsIdInput" :collection="collection" @errorMsg="handleErrMsg"/>
          </el-tab-pane>
          <el-tab-pane label="Person Relations" name="per-rel">
            <PersonRelPane :newsId="newsId" :newsIdInput="newsIdInput" :collection="collection" @errorMsg="handleErrMsg"/>
          </el-tab-pane>
          <el-tab-pane label="Sentiment" name="sentiment">
            <SentimentPane :newsId="newsId" :newsIdInput="newsIdInput" :collection="collection" @errorMsg="handleErrMsg"/>
          </el-tab-pane>
          <el-tab-pane label="Relation" name="relation">
            <RelationPane :newsId="newsId" :newsIdInput="newsIdInput" :collection="collection" @errorMsg="handleErrMsg"/>
          </el-tab-pane>
        </el-tabs>
      </div>
      <el-empty v-else description="No collection available" />
    </el-main>
  </el-container>
  </el-container>
</template>

<script setup>

</script>

<script>

import { fixAuthor } from "~/common";
import axios from 'axios'
import SemanticParsingPane from "~/components/SemanticParsingPane.vue";
import NERPane from "~/components/NERPane.vue";
import SentimentPane from "~/components/SentimentPane.vue";
import RelationPane from "~/components/RelationPane.vue";

export default {
  data() { return {
      availableCollections: [],
      collection: null,
      newsIdInput: "jnQqSH8B-NK2HObsTr5c",
      newsId: null,
      nerNewsId: null,
      newsInfo: null,
      newsInfoLoading: false,
      errMsg: "",
      activeTab: "ner",
      selectedMention: { /* temporary */
        sentIdx: null,
        tokenIdx: null
      },
    }
  },
  components: [SemanticParsingPane, NERPane, SentimentPane, RelationPane],
  methods: {
    loadNews(mode) {
      this.errMsg = ""
      this.newsInfoLoading = true
      this.nerOutput = null
      this.newsInfo = {
        title: "Loading",
        author: "Loading",
        content: "Loading",
        published: "Loading",
        url: "Loading",
      }
      this.selectedMention = {
        sentIdx: null,
        tokenIdx: null
      }
      this.newsId = null
      this.nerOutput = null
      this.nerNewsId = null

      let newsId = this.newsIdInput.slice()
      let method = "GET"
      let reqData = null
      if (mode === "random") {
        newsId = "random"
      } else {
        if (newsId.includes(".") || newsId.includes(":")) {
          method = "POST"
          newsId = "import"
          reqData = {
            url: this.newsIdInput.slice()
          }
        }
      }

      axios({
        url: `${this.api}/news/${newsId}`,
        method: method,
        data: reqData,
        params: {collection: this.collection}
      }).then((response) => {
        this.newsInfo = response.data
        this.newsInfo.author = fixAuthor(response.data.author)
        this.newsIdInput = response.data.id
        this.newsId = response.data.id
      }).catch((error) => {
        this.handleErrMsg(error)
        this.newsInfo = null
      }).then(() => {
        this.newsInfoLoading = false
      })
    },
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
    refreshURL() {
      const searchParams = new URLSearchParams(window.location.search)
      if (this.collection) {
        searchParams.set("collection", this.collection)
      }
      if (this.newsId) {
        searchParams.set("doc", this.newsId)
      }
      const newRelPathQuery =  window.location.pathname + '?' + searchParams.toString()
      history.pushState(null, null, newRelPathQuery)
    },
    loadCollections() {
      axios.get(`${this.api}/admin/collections`).then((resp) => {
        this.availableCollections = resp.data
        if (this.availableCollections.length === 0) {
          this.collection = null
        } else if (!this.availableCollections.includes(this.collection)) {
          this.collection = this.availableCollections[0]
        }
        localStorage.setItem("collections", JSON.stringify(resp.data))
      }).catch((err) => {
        this.handleErrMsg(err, "Unable to load available collections.")
      })
    },
    openLink(link) {
      window.open(link, '_blank').focus()
    }
  },
  mounted() {
    const queryString = window.location.search
    const urlParams = new URLSearchParams(queryString)
    const doc = urlParams.get("doc")
    if (doc) {
      this.newsIdInput = doc
    }
    const coll = urlParams.get("collection")
    if (coll) {
      this.collection = coll
      this.availableCollections = [coll]
    } else if (localStorage.getItem("coll")) {
      this.collection = localStorage.getItem("coll")
    }
    const list = JSON.parse(localStorage.getItem("collections"))
    if (list !== null && list.length > 0) {
      this.availableCollections = list
      if (this.collection === null) {
        this.collection = this.availableCollections[0]
      } else if (!this.availableCollections.includes((this.collection))) {
        this.collection = null
      }
    }
    this.loadCollections()
  },
  watch: {
    collection: function(newValue) {
      this.newsId = null
      localStorage.setItem("coll", newValue)
      this.refreshURL()
    },
    newsId: function(newValue) {
      if (newValue === null) return
      this.refreshURL()
    }
  }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  height: 100vh
}

.el-popper {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.token {
  padding-left: 2px;
  padding-right: 2px;
}

.sentence {
  display: flex;
  margin-top: 30px;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: flex-start;
  align-items: center;
}

.unresolved {
  text-decoration: underline dotted;
}

.highlighted {
  background-color: yellow;
}

</style>
