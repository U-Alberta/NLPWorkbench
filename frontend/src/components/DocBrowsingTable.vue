<template>
  <div>
    <div>
      Number of documents: {{preview.gte ? '&ge;' : ''}}{{ preview.total }}
    </div>
    <el-table :data="preview.hits" v-loading="previewLoading">
      <el-table-column type="expand">
        <template #default="props">
          <div>{{props.row.fields.content[0]}}</div>
        </template>
      </el-table-column>
      <el-table-column prop="id" label="ID"/>
      <el-table-column prop="fields.author" label="Author"/>
      <el-table-column prop="fields.title" label="Title"/>
      <el-table-column fixed="right" width="60">
        <template #default="scope">
          <el-tooltip
              content="Run analysis tools"
              placement="bottom">
            <el-button size="small" @click="openDoc(scope.row)">
              <el-icon>
                <MagicStick />
              </el-icon>
            </el-button>
          </el-tooltip>
        </template>
      </el-table-column>
    </el-table>
    <el-pagination layout="prev, pager, next" :total="preview.total" v-model:current-page="previewPage"/>
  </div>
</template>

<script>
import axios from "axios";
import {fixAuthor} from "../common";

export default {
  name: "DocBrowsingTable",
  props: ["esQuery", "index"],
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      preview: {
        total: 0,
        hits: []
      },
      previewLoading: false,
      previewPage: 1,
    }
  },
  methods: {
    loadPreview: function() {
      if (!this.index || !this.esQuery) {
        return
      }
      const req = {
        index: this.index,
        query: this.esQuery,
        skip: (this.previewPage - 1) * 10
      }
      /* might temper with pager
      this.preview = {
        total: 0,
        hits: []
      }
       */
      this.previewLoading = true

      const that = this
      axios.post(`${this.api}/admin/preview`, req).then((resp) => {
        let hits = resp.data.hits
        hits.forEach((value) => {
          console.log(value)
          let authorStr = value.fields.author[0]
          value.fields.author = fixAuthor(authorStr)
        })
        that.preview = resp.data
        console.log("loaded preview")
      }).catch((e) => {
        console.error(e)
        that.$emit("errorMsg", e)
        that.preview = {
          total: 0,
          hits: []
        }
      }).then(() => {
        that.previewLoading = false
      })
    },
    openDoc: function(row) {
      let link = `/?collection=${this.index}&doc=${row.id}`
      window.open(link, '_blank').focus()
    },
  },
  watch: {
    esQuery() {
      this.loadPreview()
    },
    index() {
      this.loadPreview()
    },
    previewPage(newPage, oldPage) {
      this.loadPreview()
    }
  },
  mounted() {
    this.loadPreview()
  }
}
</script>

<style scoped>

</style>