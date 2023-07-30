<template>
  <el-container style="height: 100vh">
    <el-header v-if="errMsg || successMsg" style="height: auto; margin-top: 20px; margin-bottom: 20px">
      <el-alert v-if="errMsg" :title="errMsg" type="error" class="alert"  @close="errMsg = ''"/>
      <el-alert v-if="successMsg" :title="successMsg" type="success" class="alert" @close="successMsg=''" />
    </el-header>
    <el-main>
      <CrimeClassifierTab v-if="view === 'classifiers'" @error-msg="handleErr" :document-id="documentId" :collection="collection"></CrimeClassifierTab>
      <PersonRelTab v-else-if="view === 'person-relations'" @error-msg="handleErr" :document-id="documentId" :collection="collection"></PersonRelTab>
      <RelationTab v-else-if="view === 'relations'" @error-msg="handleErr" :document-id="documentId" :collection="collection"></RelationTab>
      <SemanticParsingTab v-else-if="view === 'semantic-parsing'" @error-msg="handleErr" :document-id="documentId" :collection="collection"></SemanticParsingTab>
      <el-empty v-else description="Please specify a correct view."></el-empty>
    </el-main>
  </el-container>
</template>

<script>
import {defineComponent} from 'vue'
import CrimeClassifierTab from "~/components/nlp/ClassifierTab.vue";
import PersonRelTab from "~/components/nlp/PersonRelTab.vue";
import RelationTab from "~/components/nlp/RelationTab.vue";
import SemanticParsingTab from "~/components/nlp/SemanticParsingTab.vue";

export default defineComponent({
  name: "FullscreenApp",
  components: {CrimeClassifierTab, PersonRelTab, RelationTab, SemanticParsingTab},
  data() {
    return {
      view: null,
      documentId: null,
      collection: null,
      errMsg: null,
      successMsg: null,
    }
  },
  methods: {
    handleErr(e, prefix) {
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
    }
  },
  mounted() {
    const urlParams = new URLSearchParams(window.location.search)
    this.view = urlParams.get("view")
    this.documentId = urlParams.get("documentId")
    this.collection = urlParams.get("collection")
    document.title = urlParams.get("title")
  }
})
</script>

<style scoped>

</style>