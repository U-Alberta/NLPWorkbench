<template>
  <h4 style="text-align: left">Create Empty Collection</h4>

  <el-form label-width="120px" :model="form" :rules="formRules" ref="formEl">
    <el-form-item label="Name" prop="name">
      <el-input v-model="form.name"/>
    </el-form-item>
    <el-form-item label="Description">
      <el-input v-model="form.description" type="textarea"/>
    </el-form-item>
    <el-form-item>
      <el-button type="primary" :loading="submitLoading" :disabled="!validated"
                 @click="submit">Create
      </el-button>
    </el-form-item>
  </el-form>
</template>

<script>
import axios from "axios";

export default {
  name: "CreateCollectionPane",
  emits: ["errorMsg", "successMsg"],
  data() {
    return {
      formEl: undefined,
      form: {
        name: "",
        description: ""
      },
      formRules: {
        name: [
          {required: true, min: 1, trigger: 'blur', message: "Collection name is required"},
          {
            validator: (rule, value, callback) => {
              if (value.length > 0 && !/[a-z0-9-_]+$/.test(value)) {
                return callback(new Error('Collection name can only contain lower-case letters, numbers, underscore and dash.'))
              } else {
                return callback()
              }
            },
            trigger: 'change'
          }
        ]
      },
      submitLoading: false
    }
  },
  methods: {
    submit() {
      this.submitLoading = true
      const req = {
        description: this.form.description
      }
      axios.put(`${this.api}/collection/${this.form.name}`, req).then((resp) => {
        const successMsg = `Collection created.`
        this.$emit("successMsg", successMsg)
        this.form = {
          name: "",
          description: ""
        }
      }).catch((e) => {
        console.log(e)
        this.$emit("errorMsg", e)
      }).then(() => {
        this.submitLoading = false
      })
    }
  },
  computed: {
    validated: function() {
      return /^[a-z0-9-_]+$/.test(this.form.name)
    }
  }
}
</script>

<style scoped>

</style>