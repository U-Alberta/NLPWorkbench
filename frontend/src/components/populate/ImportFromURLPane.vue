<template>
  <el-form label-width="120px" v-model="form">
    <el-form-item>
      Import the web page content of the given URL
    </el-form-item>
    <el-form-item label="URL" prop="url">
      <el-input v-model="form.url" />
    </el-form-item>
    <el-form-item>
      <el-button :loading="submitLoading"
                 :disabled="!collection || !form.url"
                 @click="submit">Import
      </el-button>
    </el-form-item>
  </el-form>
  <div v-if="preview">
    <el-descriptions v-if="preview" title="Document Info">
      <el-descriptions-item label="Title">{{ preview.title }}</el-descriptions-item>
      <el-descriptions-item label="Author">{{ preview.author }}</el-descriptions-item>
      <el-descriptions-item label="Published">{{preview.published}}</el-descriptions-item>
      <el-descriptions-item label="URL">{{preview.url}}</el-descriptions-item>
    </el-descriptions>
    <el-collapse v-if="preview">
      <el-collapse-item title="Content">
        <div style="text-align: left">{{preview.text}}</div>
      </el-collapse-item>
    </el-collapse>
    <!-- Jump to document not implemented -->
    <!--
    <el-button style="margin-top: 20px; margin-left: 20px" type="primary" @click="openLink('/?collection='+this.collection+'&doc='+this.preview.id)">
      <el-icon><MagicStick /></el-icon>&nbsp;Analyze
    </el-button>
    -->
  </div>
</template>

<script>
import axios from "axios";

export default {
  name: "ImportFromURLPane",
  props: ["collection"],
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      submitLoading: false,
      form: {
        url: "https://en.wikinews.org/wiki/Microsoft,_Nware_sign_10-year_cloud_gaming_deal",
      },
      preview: null,
      formRules: {
        url: [
          {required: true, min: 1, trigger: 'blur', message: "URL is required"},
          {
            validator: (rule, value, callback) => {
              if (value.length > 0 && !/^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)$/.test(value)) {
                return callback(new Error('Invalid URL'))
              } else {
                return callback()
              }
            },
            trigger: 'change'
          }
        ]
      },
    }
  },
  methods: {
    openLink: function(link) {
      window.open(link, '_blank').focus()
    },
    submit() {
      if (this.collection.trim() === '') {
        return
      }
      this.submitLoading = true
      const req = {
        url: this.form.url
      }
      axios.post(`${this.api}/collection/${this.collection}/doc/_import_from_url`, req).then((resp) => {
        const successMsg = `Document imported.`
        this.$emit("successMsg", successMsg)
        this.form.url = ""
        this.preview = resp.data
      }).catch((e) => {
        console.log(e)
        this.$emit("errorMsg", e)
      }).then(() => {
        this.submitLoading = false
      })
    }
  },
  watch: {
    collection: function () {
      this.preview = null
    }
  }

}
</script>

<style scoped>

</style>