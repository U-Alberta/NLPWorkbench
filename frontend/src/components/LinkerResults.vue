<template>
<div style="padding: 10px;">
  <h4 style="text-align: left">Linker Output</h4>
  <el-alert v-if="errMsg" :title="errMsg" type="error" style="margin-top: 20px;"/>
  <div v-if="candidates === null" style="color: #8c939d">select a mention first.</div>
  <el-empty v-if="!linkerLoading && candidates !== null && candidates.length === 0" description="No entity matched."></el-empty>
  <div class="candidate" v-for="(candidate, candidateIdx) in candidates" v-loading="linkerLoading">
    <el-descriptions :title="candidate.entity_id" :column="1">
      <el-descriptions-item label="Score">{{candidate.score.toFixed(2)}}</el-descriptions-item>
      <el-descriptions-item label="Names">{{candidate.names.join("; ")}}</el-descriptions-item>
    </el-descriptions>
    <el-button size="small" round @click="openLink(browserLink(candidate.entity_id))"><el-icon><Link /></el-icon>&nbsp; Neo4j Browser</el-button>
    <el-button size="small" round @click="openLink(`https://wikidata.org/wiki/${candidate.entity_id}`)"><el-icon><Search /></el-icon>&nbsp; Wikidata</el-button>
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
</template>

<script>
import axios from "axios";

export default {
  name: "LinkerResults",
  props: ["newsId", "sentIdx", "tokenIdx", "collection"],
  data() { return {
      linkerLoading: false,
      candidates: null,
      errMsg: null,
      openedCollapse: [[]]
    }
  },
  methods: {
    browserLink(entityId) {
      let query = `MATCH (e: Entity {entityId: "${entityId}"}) RETURN e;`
      let dbms = `neo4j+s://neo4j@${this.host}:9201`
      return `${this.server}/browser/?cmd=edit&arg=${encodeURIComponent(query)}&dbms=${encodeURIComponent(dbms)}`
    },
    runLinker() {
      this.errMsg = ""
      let that = this
      if (this.newsId === null || this.sentIdx === null || this.tokenIdx === null) {
        this.candidates = []
        this.openedCollapse = []
        return null
      }
      this.linkerLoading = true
      this.candidates  = [
        {
          entity_id: "Loading",
          names: ["Loading"],
          score: "Loading"
        }
      ]
      this.openedCollapse = [[]]
      axios.get(`${this.api}/link/${this.newsId}/${this.sentIdx}/${this.tokenIdx}`,
          {params: {collection: this.collection}}
      ).then(function (response) {
        that.candidates = response.data
        that.openedCollapse = that.candidates.map(() => [])
      }).catch(function(error) {
        that.candidates = null
        that.errMsg = error.message
      }).then(function() {
        that.linkerLoading = false
      })
    },
    onCollapseChange(candidate, activeNames) {
      let that = this
      if (activeNames.includes("attributes") && candidate.attributes === undefined) {
        axios.get(
          `${this.api}/entity/${candidate.entity_id}/attributes`,
          {params: {collection: this.collection}}
          ).then(function (response) {
          candidate.attributes = response.data
        }).catch(function(error) {
          that.errMsg = error.message
        })
      }
      if (activeNames.includes("description") && candidate.description === undefined) {
        axios.get(
          `${this.api}/entity/${candidate.entity_id}/description`,
          {params: {collection: this.collection}}
          ).then(function (response) {
          candidate.description = response.data.description
        }).catch(function(error) {
          that.errMsg = error.message
        })
      }
    },
    openLink(link) {
      window.open(link, '_blank').focus()
    }
  },
  watch: {
    newsId(newValue) {
      //this.runLinker()
      this.candidates = null
      this.openedCollapse = []
    },
    sentIdx(newValue) {
      this.runLinker()
    },
    tokenIdx() {
      this.runLinker()
    }
  }
}
</script>

<style scoped>
.candidate {
  text-align: left;
  margin-top: 16px;
  margin-bottom: 16px;
  padding: 5px;
  border: 1px solid #cccccc;
  border-radius: var(--el-border-radius-base);
  }
</style>
