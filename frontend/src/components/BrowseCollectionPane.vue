<template>
  <h4 style="text-align: left">Browse documents in a collection</h4>

  <el-form label-width="120px" :model="form">
    <el-form-item label="Collection" prop="collection">
      <el-select v-model="form.collection" filterable placeholder="Select" :loading="collectionListLoading" loading-text="Loading...">
        <el-option
            v-for="item in collections"
            :key="item"
            :label="item"
            :value="item"
        />
      </el-select>
    </el-form-item>
    <el-form-item label="KQL">
      <el-input v-model="form.kql" type="textarea"/>
      <el-link type="info" href="https://www.elastic.co/guide/en/kibana/current/kuery-query.html" target="_blank">
        What's KQL?
      </el-link>
    </el-form-item>
    <el-form-item>
      <el-button type="primary" :disabled="!form.collection" @click="runQuery">Run Query</el-button>
    </el-form-item>
  </el-form>
  <DocBrowsingTable
      v-if="finalQuery !== null && finalIndex !== null"
      @errorMsg="(x) => $.emit('errorMsg', x)"
      @successMsg="(x)=>$.emit('successMsg', x)"
      :es-query="finalQuery"
      :index="finalIndex"
  />
</template>

<script>
import axios from "axios";
import {buildEsQuery} from "@cybernetex/kbn-es-query";
import DocBrowsingTable from "~/components/DocBrowsingTable.vue";

export default {
  name: "BrowseCollectionPane",
  components: {DocBrowsingTable},
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      form: {
        collection: "",
        kql: ""
      },
      collections: [],
      collectionListLoading: false,
      finalQuery: null,
      finalIndex: null
    }
  },
  mounted() {
    this.collectionListLoading = true
    axios.get(`${this.api}/snc/indexes`).then((resp) => {
      this.collections = resp.data
    }).catch((e) => {
      console.log(e)
      this.$emit("errorMsg", e)
    }).then(() => {
      this.collectionListLoading = false
    })
  },
  methods: {
    runQuery: function() {
      let dsl;
      if (this.form.kql.trim() === "") {
        dsl = {
          match_all: {}
        }
      } else {
        dsl = buildEsQuery(undefined, {language: "kuery", query: this.form.kql})
      }
      this.finalIndex = this.form.collection
      this.finalQuery = dsl
    },
  }
}
</script>

<style scoped>

</style>