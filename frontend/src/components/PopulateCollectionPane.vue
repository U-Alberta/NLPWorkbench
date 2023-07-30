<template>
  <h4 style="text-align: left">Import documents into a collection</h4>

  <el-form label-width="120px" :model="form">
    <el-form-item label="Collection" prop="collection">
      <el-select v-model="form.collection" filterable placeholder="Select" :loading="collectionListLoading"
        loading-text="Loading...">
        <el-option v-for="item in collections" :key="item" :label="item" :value="item" />
      </el-select>
    </el-form-item>
    <el-form-item label="Source" prop="source">
      <el-select v-model="form.source" placeholder="Select">
        <el-option label="Web Page (from URL)" value="webpage" />
        <el-option label="News / Web Page Search" value="search" />
      </el-select>
    </el-form-item>
  </el-form>
  <div v-if="form.collection.trim() !== ''">
    <PopulateBySearchPane v-if="form.source === 'search'" :collection="form.collection"
      @errorMsg="(x) => $emit('errorMsg', x)" @successMsg="(x) => $emit('successMsg', x)"
      @enterKeys="$emit('enterKeys')" />
    <ImportFromURLPane v-if="form.source === 'webpage'" :collection="form.collection"
      @errorMsg="(x) => $emit('errorMsg', x)" @successMsg="(x) => $emit('successMsg', x)" />
  </div>
</template>

<script>
import axios from "axios";
import PopulateBySearchPane from "./populate/PopulateBySearchPane.vue";
import ImportFromURLPane from "~/components/populate/ImportFromURLPane.vue";

export default {
  name: "PopulateCollectionPane",
  components: {PopulateBySearchPane, ImportFromURLPane},
  emits: ["errorMsg", "successMsg", "enterKeys"],
  data() {
    return {
      collections: [],
      collectionListLoading: false,
      form: {
        collection: "",
        source: "webpage"
      }
    }
  },
  methods: {
    loadCollections() {
      this.collectionListLoading = true
      axios.get(`${this.api}/collection/`).then((resp) => {
        this.collections = resp.data
      }).catch((e) => {
        console.log(e)
        this.$emit("errorMsg", e)
      }).then(() => {
        this.collectionListLoading = false
      })
    },
    openLink: function (link) {
      window.open(link, '_blank').focus()
    }
  },
  mounted() {
    this.loadCollections()
  }
}
</script>

<style scoped></style>
