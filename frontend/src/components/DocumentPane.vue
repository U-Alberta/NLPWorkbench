<template>
  <el-container style="height: 100%">
    <el-header class="header" style="padding-bottom: 10px" v-if="this.selectedDoc"
               @click="searchBoxOpen=!searchBoxOpen">
      <el-row>
        <el-col :span="20">
          <el-breadcrumb separator="/" style="display: flex">
            <el-breadcrumb-item>{{ this.collection }}</el-breadcrumb-item>
            <el-breadcrumb-item>
              <b style="font-size: 14pt">
                {{ this.selectedDoc.fields.title[0] }}
              </b>
            </el-breadcrumb-item>
          </el-breadcrumb>
        </el-col>
        <el-col :span="4" style="display: flex; align-items: center; justify-content: flex-end">
          <el-button-group>
            <el-button size="small" @click.stop="searchBoxOpen=!searchBoxOpen">
              <el-icon>
                <search/>
              </el-icon>
            </el-button>
            <el-button
                size="small"
                @click.stop="selectedDocIndex=(selectedDocIndex === 0 ? 0: selectedDocIndex - 1)"
                :disabled="selectedDocIndex===0"
            >
              <el-icon>
                <arrow-left/>
              </el-icon>
            </el-button>
            <el-button
                size="small"
                @click.stop="selectedDocIndex=(selectedDocIndex < totalDocs-1 ? selectedDocIndex + 1: selectedDocIndex)"
                :disabled="selectedDocIndex===totalDocs-1"
            >
              <el-icon>
                <arrow-right/>
              </el-icon>
            </el-button>
          </el-button-group>
        </el-col>
      </el-row>
    </el-header>
    <el-header class="header" v-show="searchBoxOpen"> <!-- expanded: document search -->
      <el-form label-width="auto" label-position="right">
        <el-form-item class="searchbox-item" label="Collection">
          <el-select v-model="collection" filterable placeholder="Select" :loading="collectionListLoading"
                     loading-text="Loading...">
            <el-option
                v-for="item in availableCollections"
                :key="item"
                :label="item"
                :value="item"
            />
          </el-select>
        </el-form-item>
        <el-form-item class="searchbox-item" label="Query">
          <el-input v-model="kql" type="textarea" autosize placeholder="title: &quot;banking&quot;"/>
          <el-link type="info" href="https://www.elastic.co/guide/en/kibana/current/kuery-query.html" target="_blank">
            <el-icon>
              <question-filled/>
            </el-icon>&nbsp;How to write queries?
          </el-link>
        </el-form-item>
        <el-form-item class="searchbox-item" label=" ">
          <el-button type="primary" :disabled="!collection" @click="runQuery">
            <el-icon>
              <search/>
            </el-icon>&nbsp;Search
          </el-button>
        </el-form-item>
        <DocBrowsingTable
            v-if="finalQuery !== null && collection"
            @errorMsg="(x) => $emit('errorMsg', x)"
            @successMsg="(x)=>$emit('successMsg', x)"
            @docSelected="selectDoc"
            @docsLoaded="(x)=>this.totalDocs = x"
            :es-query="finalQuery"
            :index="collection"
            :inf-scroll="true"
            :as-selector="true"
            table-height="200px"
            :selected-row-index="selectedDocIndex"
        />
      </el-form>
    </el-header>
    <el-empty v-if="!documentId" description="Search and select a document to start."></el-empty>
    <el-container v-if="documentId" ref="docContainer" style="height: 100%" @mousemove="onSidebarMouseMove"
                  @mouseup="onSidebarMouseUp"
                  @mouseleave="onSidebarMouseLeave">
      <el-main v-show="!sidebarFull" style="padding-top: 5px">
        <NERTab :documentId="documentId" :collection="collection"
                @errorMsg="handleErrMsg" @selected="onSelectMention"/>
      </el-main>
      <el-aside :class="{sidebar: true, 'sidebar-noborder': sidebarFull || sidebarDraggerHover}"
                :width="sidebarWidth + 'px'">
        <div v-show="!sidebarFull" class="dragger" @mousedown.prevent="onSidebarMouseDown"
             @mouseenter="sidebarDraggerHover=true" @mouseleave="sidebarDraggerHover=false">
        </div>
        <div style="width: calc(100% - 8px)">
          <el-row :justify="sidebarWidth <= 60 ? 'space-around' : 'start'">
            <el-button
                v-if="sidebarWidth <= 60"
                size="small"
                style="margin-top: 8px;"
                @click="sidebarWidth=300"
            >
              <el-icon>
                <d-arrow-left/>
              </el-icon>
            </el-button>
            <el-button
                v-else
                size="small"
                style="margin-top: 8px; margin-left: 10px"
                @click="onSidebarExpand"
            >
              <el-icon>
                <d-arrow-right/>
              </el-icon>
            </el-button>
          </el-row>
          <el-collapse v-if="sidebarWidth > 60" style="margin-top: 8px; padding: 0 10px 0 10px" v-model="activeTools">
            <el-collapse-item title="Document Info" name="description">
              <div v-loading="documentInfoLoading" v-if="activeTools.includes('description')">
                <el-descriptions v-if="documentInfo" :column="1" size="small">
                  <el-descriptions-item label="Title">{{ documentInfo.title }}</el-descriptions-item>
                  <el-descriptions-item v-if="documentInfo.author" label="Author">{{
                      documentInfo.author
                    }}
                  </el-descriptions-item>
                  <el-descriptions-item v-if="documentInfo.published" label="Published">{{
                      documentInfo.published
                    }}
                  </el-descriptions-item>
                  <el-descriptions-item v-if="documentInfo.url" label="URL">{{
                      documentInfo.url
                    }}
                  </el-descriptions-item>
                  <el-descriptions-item label="ID">{{ documentInfo.id }}</el-descriptions-item>
                </el-descriptions>
              </div>
            </el-collapse-item>
            <SidebarItem name="classifiers" title="Classification"
                         :document-id="documentId"
                         :collection="collection"
                         viewable-in-fullscreen>
              <ClassifierTab v-if="activeTools.includes('classifiers')" :documentId="documentId"
                             :collection="collection"
                             @errorMsg="handleErrMsg"/>
            </SidebarItem>
            <SidebarItem name="relations" title="All Relations"
                         :document-id="documentId"
                         :collection="collection"
                         viewable-in-fullscreen>
              <RelationTab v-if="activeTools.includes('relations')"
                           :documentId="documentId" :collection="collection"
                           @errorMsg="handleErrMsg"/>
            </SidebarItem>
            <SidebarItem name="person-relations" title="Person Relations"
                         :document-id="documentId"
                         :collection="collection"
                         viewable-in-fullscreen>
              <PersonRelTab v-if="activeTools.includes('person-relations')"
                            :documentId="documentId" :collection="collection"
                            @errorMsg="handleErrMsg"/>
            </SidebarItem>
            <SidebarItem name="linker" title="Entity Linker"
                         :document-id="documentId"
                         :collection="collection">
              <LinkerResults
                  v-if="activeTools.includes('linker')"
                  :documentId="documentId" :collection="collection" :sent-idx="selectedMention.sentIdx"
                  :token-idx="selectedMention.tokenIdx"
                  @errorMsg="handleErrMsg"/>
            </SidebarItem>
            <SidebarItem name="semantic-parsing" title="Semantic Parsing"
                         :document-id="documentId"
                         :collection="collection"
                         viewable-in-fullscreen>
              <SemanticParsingTab
                  v-if="activeTools.includes('semantic-parsing')"
                  :documentId="documentId" :collection="collection"
                  @errorMsg="handleErrMsg"/>
            </SidebarItem>
          </el-collapse>
        </div>
      </el-aside>
    </el-container>
  </el-container>
</template>

<script>
import {defineComponent} from "vue";
import {fixAuthor} from "~/common";
import axios from 'axios'
import SemanticParsingTab from "~/components/nlp/SemanticParsingTab.vue";
import NERTab from "~/components/nlp/NERTab.vue";
import RelationTab from "~/components/nlp/RelationTab.vue";
import PersonRelTab from "~/components/nlp/PersonRelTab.vue";
import ClassifierTab from "~/components/nlp/ClassifierTab.vue";
import DocBrowsingTable from "~/components/DocBrowsingTable.vue";
import LinkerResults from "~/components/nlp/LinkerResults.vue";
import SidebarItem from "~/components/SidebarItem.vue";
import {buildEsQuery} from "@cybernetex/kbn-es-query";
import {
  ArrowLeft,
  ArrowRight,
  DArrowLeft,
  DArrowRight,
  FullScreen,
  QuestionFilled,
  Search,
  TopLeft
} from "@element-plus/icons-vue";

export default defineComponent({
  name: "DocumentPane",
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      searchBoxOpen: true,
      availableCollections: [],
      collectionListLoading: false,
      kql: "",
      selectedDocIndex: 0,
      totalDocs: 0,
      finalQuery: undefined,
      collection: null,
      selectedDoc: null,
      documentId: null,
      documentInfo: null,
      documentInfoLoading: false,
      trackSidebarDrag: false,
      sidebarSliderOrigin: null,
      oldsidebarWidth: 300,
      sidebarWidth: 300,
      sidebarDraggerHover: false,
      sidebarFull: false,
      activeTools: ["description", "relations", "person-relations", "classifiers"],
      selectedMention: {
        sentIdx: null,
        tokenIdx: null
      }
    }
  },
  components: {
    QuestionFilled,
    ArrowRight,
    ArrowLeft,
    Search,
    DArrowRight,
    DArrowLeft,
    ClassifierTab,
    LinkerResults,
    FullScreen,
    TopLeft,
    SidebarItem,
    SemanticParsingTab, NERTab, RelationTab, PersonRelTab, DocBrowsingTable
  },
  methods: {
    selectDoc(row) {
      this.selectedDocIndex = row.index
      this.documentId = row.id
      this.selectedDoc = row
      this.searchBoxOpen = false
      this.loadDocument()
    },
    runQuery() {
      let dsl;
      if (this.kql.trim() === "") {
        dsl = {
          match_all: {}
        }
      } else {
        dsl = buildEsQuery(undefined, {language: "kuery", query: this.kql})
      }
      //this.finalIndex = this.form.collection
      this.finalQuery = dsl
    },
    loadDocument(mode) {
      this.$emit("errorMsg", "")
      this.documentInfoLoading = true
      this.documentInfo = {
        title: "Loading",
        author: "Loading",
        content: "Loading",
        published: "Loading",
        url: "Loading",
      }
      let documentId = this.documentId
      if (mode === "random") {
        documentId = "_random"
      }

      axios.get(
          `${this.api}/collection/${this.collection}/doc/${documentId}?skip_text=1`
      ).then((response) => {
        this.documentInfo = response.data
        this.documentInfo.author = fixAuthor(response.data.author)
      }).catch((error) => {
        this.$emit("errorMsg", error)
        this.documentInfo = null
      }).then(() => {
        this.documentInfoLoading = false
      })
    },
    loadCollections() {
      axios.get(`${this.api}/collection/`).then((resp) => {
        this.availableCollections = resp.data
        if (this.availableCollections.length === 0) {
          this.collection = null
        } else {
          this.collection = this.availableCollections[0]
        }
      }).catch((err) => {
        console.error(err)
        this.$emit("errorMsg", err, "Unable to load available collections.")
      })
    },
    openLink(link) {
      window.open(link, '_blank').focus()
    },
    handleErrMsg(e, prefix) {
      this.$emit("errorMsg", e, prefix)
    },
    onSidebarMouseDown(e) {
      this.trackSidebarDrag = true
      this.sidebarSliderOrigin = e.clientX;
      this.oldsidebarWidth = this.sidebarWidth
    },
    onSidebarMouseMove(e) {
      if (!this.trackSidebarDrag) return
      const delta = this.sidebarSliderOrigin - e.clientX
      this.sidebarWidth = Math.max(this.sidebarWidth + delta, 60)
      this.sidebarSliderOrigin = e.clientX
    },
    onSidebarMouseUp(e) {
      this.trackSidebarDrag = false
      const parentWidth = this.$refs.docContainer.$el.clientWidth
      if (this.sidebarWidth > parentWidth * 0.8) {
        this.sidebarWidth = parentWidth
        this.sidebarFull = true
      } else {
        this.sidebarFull = false
      }

      if (this.sidebarWidth < 180) {
        /* too small, can't display properly */
        if (this.oldsidebarWidth >= 180) {
          /* user is trying to shrink. help them minimize */
          this.sidebarWidth = 60
        } else {
          /* user is trying to enlarge. help them enlarge to minimum displayable width */
          this.sidebarWidth = 180
        }
      }
    },
    onSidebarMouseLeave(e) {
      this.sidebarDraggerHover = false
      this.onSidebarMouseUp(e)
    },
    onSidebarExpand(e) {
      this.sidebarFull = false
      if (this.sidebarWidth <= 300) {
        this.sidebarWidth = 60
      } else {
        this.sidebarWidth = 300
      }
    },
    openNewWindow(view, title) {
      const params = new URLSearchParams()
      params.append("view", view)
      params.append("title", title)
      params.append("documentId", this.documentId)
      params.append("collection", this.collection)
      const url = `/fullscreen/?${params.toString()}`
      window.open(url, '_blank', "popup").focus()
    },
    onSelectMention(mention) {
      this.selectedMention = mention
      if (!this.activeTools.includes("linker")) {
        this.activeTools.push("linker")
      }
      // must be called twice because there are multiple scrollbars
      this.$refs.linker.$el.scrollIntoView()
      this.$refs.linker.$el.scrollIntoView() // should not be removed
    }
  },
  mounted() {
    this.loadCollections()
  },
  watch: {
    collection: function (newValue) {
      this.documentId = null
      this.selectedDoc = null
    },
  }
})
</script>

<style scoped>
.searchbox-item {
  margin-bottom: 10px;
}

.header {
  padding-top: 10px;
  height: auto;
  box-shadow: 0 1px 2px rgba(60,64,67,0.3), 0 2px 6px 2px rgba(60,64,67,0.15)
}

.dragger {
  position: fixed;
  height: 100%;
  width: 8px;
  background-color: #ccc;
  cursor: ew-resize;
  opacity: 0;
  transition: opacity 0.3s;
}

.dragger:hover {
  opacity: 1;
}

.sidebar {
  min-width: 60px;
  display: flex;
  flex-direction: row;
  transition: border-left 0.3s;
  padding-right: 8px;
  border-left: 1px solid #dadce0;
}

.sidebar-noborder {
  border-left: 1px solid #ffffff;
}


</style>