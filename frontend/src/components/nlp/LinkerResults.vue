<template>
<div style="padding: 2px;">
  <div v-if="sentIdx === null" style="color: #8c939d">Select a mention first.</div>
  <el-empty v-if="!linkerLoading && candidates !== null && candidates.length === 0" description="No entity matched."></el-empty>
  <div v-if="sentIdx !== null">
    <div class="candidate" v-for="(candidate, candidateIdx) in candidates" v-loading="linkerLoading">
      <el-descriptions :title="candidate.entity_id" :column="1">
        <el-descriptions-item label="Score">{{candidate.score.toFixed(2)}}</el-descriptions-item>
        <el-descriptions-item label="Names">{{candidate.names.join("; ")}}</el-descriptions-item>
      </el-descriptions>
      <el-button size="small" round @click="openLink(browserLink(candidate.entity_id))"><el-icon><Link /></el-icon>&nbsp; Neo4j Browser</el-button>
      <el-button size="small" round @click="openLink(`https://wikidata.org/wiki/${candidate.entity_id}`)"><el-icon><search /></el-icon>&nbsp; Wikidata</el-button>
      <el-collapse
          style="margin-top: 15px; margin-bottom: 5px"
          @change="(activeNames) => onCollapseChange(candidate, activeNames)"
          v-model="openedCollapse[candidateIdx]">
        <el-collapse-item title="Attributes" name="attributes" >
          <el-empty v-if="candidate.attributes !== undefined && candidate.attributes.length === 0"></el-empty>
          <el-descriptions :column="1" v-loading="candidate.attributes === undefined">
            <el-descriptions-item v-for="attr in candidate.attributes" :label="attr.attribute">{{attr.value.join("; ")}}</el-descriptions-item>
          </el-descriptions>
        </el-collapse-item>
        <el-collapse-item title="Description" name="description">
          <p v-if="candidate.description === undefined" v-loading="true">Loading ...</p>
          <p v-else>
            {{candidate.description}}
          </p>
        </el-collapse-item>
      </el-collapse>
    </div>
  </div>
</div>
</template>

<script>
import axios from "axios";
import {Search, Link} from "@element-plus/icons-vue";

export default {
  name: "LinkerResults",
  components: {Search, Link},
  emits: ["errorMsg"],
  props: {
    documentId: {default: null},
    sentIdx: {default: null},
    tokenIdx: {default: null},
    collection: {default: null}
  },
  data() { return {
      linkerLoading: false,
      candidates: [
        {
          entity_id: "Loading",
          names: ["Loading"],
          score: 0
        }
      ],
      openedCollapse: [[]]
    }
  },
  methods: {
    browserLink(entityId) {
      let query = `MATCH (e: Entity {entityId: "${entityId}"}) RETURN e;`
      let dbms = `neo4j://neo4j@${this.host}:7687`
      return `${this.server}/browser/?cmd=edit&arg=${encodeURIComponent(query)}&dbms=${encodeURIComponent(dbms)}`
    },
    runLinker() {
      this.$emit("errorMsg", "")
      if (this.documentId === null || this.sentIdx === null || this.tokenIdx === null) {
        this.candidates = []
        this.openedCollapse = []
        return null
      }
      this.linkerLoading = true
      this.candidates  = [
        {
          entity_id: "Loading",
          names: ["Loading"],
          score: 0
        }
      ]
      this.openedCollapse = [[]]
      axios.get(`${this.api}/collection/${this.collection}/doc/${this.documentId}/link/${this.sentIdx}/${this.tokenIdx}`).then(response => {
        this.candidates = response.data
        this.openedCollapse = this.candidates.map(() => [])
      }).catch(error => {
        this.candidates = []
        this.$emit("errorMsg", error.message)
      }).then(() => {
        this.linkerLoading = false
      })
    },
    onCollapseChange(candidate, activeNames) {
      if (activeNames.includes("attributes") && candidate.attributes === undefined) {
        axios.get(
          `${this.api}/entity/${candidate.entity_id}/attributes`
          ).then(response => {
          candidate.attributes = response.data
        }).catch(error => {
          this.$emit("errorMsg", error.message)
        })
      }
      if (activeNames.includes("description") && candidate.description === undefined) {
        axios.get(
          `${this.api}/entity/${candidate.entity_id}/description`
          ).then(response => {
          candidate.description = response.data.description
        }).catch(error => {
          this.$emit("errorMsg", error.message)
        })
      }
    },
    openLink(link) {
      window.open(link, '_blank').focus()
    }
  },
  watch: {
    documentId(newValue) {
      //this.runLinker()
      this.candidates = []
      this.openedCollapse = []
    },
    sentIdx(newValue) {
      console.log("sentIdx changed")
      this.runLinker()
    },
    tokenIdx() {
      console.log("tokenIdx changed")
      this.runLinker()
    }
  },
  mounted() {
    this.runLinker()
  }
}
</script>

<style scoped>
.candidate {
  text-align: left;
  margin-bottom: 8px;
  padding: 5px;
  border: 1px solid #cccccc;
  border-radius: var(--el-border-radius-base);
  }
</style>
