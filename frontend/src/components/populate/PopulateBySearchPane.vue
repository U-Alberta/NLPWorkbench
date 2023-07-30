<template>
  <el-form label-width="120px" :model="form">
    <el-form-item>
      Import documents from Bing search
    </el-form-item>
    <el-form-item label="Query">
      <el-input v-model="form.query" type="textarea" />
    </el-form-item>
    <el-form-item label="Region/Language" prop="region">
      <el-select v-model="form.region" filterable placeholder="Select">
        <el-option v-for="item in regions" :key="item.code" :label="`${item.region} (${item.lang})`" :value="item.code" />
      </el-select>
    </el-form-item>
    <el-form-item label="Media Types">
      <el-switch v-model="form.mediaType"
        style="--el-switch-on-color: #409eff; --el-switch-off-color: #409eff; --el-text-color-primary: #aaaaaa"
        active-text="News" inactive-text="Web Page" active-value="news" inactive-value="webpage"
        :disabled="!newsSupported" />
    </el-form-item>
    <el-form-item label="Category" v-if="form.mediaType === 'news'">
      <el-select v-model="form.newsCategory">
        <el-option label="Any" value="Any" />
        <el-option v-for="item in categories" :label="item" :key="item" :value="item" />
      </el-select>
    </el-form-item>
    <el-form-item label="Date Range">
      <el-select v-model="form.freshness">
        <el-option label="Any" value="Any" />
        <el-option label="Past Day" value="Day" />
        <el-option label="Past Week" value="Week" />
        <el-option label="Past Month" value="Month" />
        <el-option label="Custom" value="Custom" v-if="form.mediaType === 'webpage'" />
      </el-select>
    </el-form-item>
    <el-form-item v-if="form.freshness === 'Custom'">
      <div style="width: 50%">
        <el-date-picker v-model="form.dateRange" type="daterange" range-separator="To" start-placeholder="Start date"
          end-placeholder="End date" :disabled-date="(time) => time.getTime() > Date.now()" />
      </div>
    </el-form-item>
    <el-form-item label="Maximum">
      <el-input-number v-model="form.maxSize" :step="20" :max="500" :min="1" />
      &nbsp; &nbsp; document(s)
    </el-form-item>
    <el-form-item>
      <el-button :loading="previewLoading" :disabled="previewLoading || !collection || !form.query"
        @click="preview">Preview
      </el-button>
      <el-button v-if="previewData" type="primary" :loading="submitLoading" :disabled="submitLoading || !previewData"
        @click="submit">Import
      </el-button>
    </el-form-item>
  </el-form>
  <!-- search result preview -->
  <span v-if="previewData" style="font-size: 14px">About {{ new Intl.NumberFormat().format(previewData.total_matches) }}
    results. <br /></span>
  <el-link v-if="previewData && previewData.mediaType === 'webpage'" :href="previewData.bing_url" target="_blank">View on
    Bing.com</el-link>
  <el-table v-if="previewData" :data="previewData.docs" style="width: 100%">
    <el-table-column v-if="previewData.mediaType === 'news'" prop="datePublished" label="Date" width="100"
      :formatter="(x) => (new Date(x.datePublished)).toLocaleDateString()" />
    <el-table-column prop="name" label="Title" width="250">
      <template #default="scope">
        <div style="hyphens: auto; word-break: normal;">
          <el-link type="info" :href="scope.row.url" target="_blank">{{ scope.row.name }}</el-link>
        </div>
      </template>
    </el-table-column>
    <el-table-column v-if="previewData.mediaType === 'news'" prop="provider" label="Provider" width="100" />
    <el-table-column prop="snippet" label="Description" />
  </el-table>
  <!-- end news preview -->
</template>

<script>
import axios from "axios";
import regions from '/src/bing_regions.json'
import categories from '/src/bing_categories.json'
import { ElMessageBox } from 'element-plus'

export default {
  name: "PopulateBySearchPane",
  props: ["collection"],
  emits: ["errorMsg", "successMsg", "enterKeys"],
  data() {
    return {
      previewLoading: false,
      form: {
        query: "",
        region: "en-CA",
        mediaType: "news",
        newsCategory: "Any",
        freshness: "Any",
        dateRange: [new Date(), new Date()],
        maxSize: 20
      },
      regions: regions,
      newsSupported: true,
      previewData: null,
      submitLoading: false,
      bingKeyPresent: localStorage.getItem("bingkey") !== null
    }
  },
  methods: {
    preview() {
      const bing = localStorage.getItem("bingkey")
      let headers = {}
      if (bing !== null) {
        headers['X-Bing-API-Key'] = bing
      }

      this.previewLoading = true
      this.form.collection = this.collection
      axios.post(`${this.api}/search_preview`, this.form, {
        headers: headers
      }).then((resp) => {
        this.previewData = resp.data
        this.previewData.docs = this.previewData.docs.slice(0, this.form.maxSize)
      }).catch((e) => {
        console.error(e)
        if (e.response && e.response.status === 403) {
          ElMessageBox.alert("Bing API key is missing. You need to provide API key to access this feature.", "API Key missing", {
            confirmButtonText: "Add Key",
            callback: (action) => {
              if (`${action}` === "confirm") {
                this.$emit('enterKeys')
              }
            }
          })
          return;
        }
        this.$emit("errorMsg", e)
      }).then((e) => {
        this.previewLoading = false
      })
    },
    openLink: function (link) {
      window.open(link, '_blank').focus()
    },
    submit() {
      const bing = localStorage.getItem("bingkey")
      let headers = {}
      if (bing !== null) {
        headers['X-Bing-API-Key'] = bing
      }
      this.submitLoading = true
      axios.post(`${this.api}/collection/${this.form.collection}/import_from_search`, this.form, {
        headers: headers
      }).then((resp) => {
        this.$emit("successMsg", "Import job submitted. Please check the collection later.")
      }).catch((e) => {
        console.error(e)
        if (e.response && e.response.status === 403) {
          ElMessageBox.alert("Bing API key is missing. You need to provide API key to access this feature.", "API Key missing", {
            confirmButtonText: "Add Key",
            callback: (action) => {
              if (`${action}` === "confirm") {
                this.$emit('enterKeys')
              }
            }
          })
          return;
        }
        this.$emit("errorMsg", e)
      }).then((e) => {
        this.submitLoading = false
      })
    },
  },
  watch: {
    'form.region': function (newValue) {
      if (!categories.hasOwnProperty(newValue)) {
        this.form.mediaType = 'webpage'
        this.newsSupported = false
      } else {
        this.newsSupported = true
      }
    },
    'form.mediaType': function (newValue) {
      if (newValue === 'news' && this.form.freshness === 'Custom') {
        this.form.freshness = 'Any'
      }
    },
    form: {
      handler() {
        this.previewData = null
      },
      deep: true
    },
    collection: function (newValue) {
      this.previewData = null
    }
  },
  computed: {
    categories() {
      console.log("compute", categories[this.form.region])
      return categories[this.form.region]
    }
  }
}
</script>

<style scoped></style>
