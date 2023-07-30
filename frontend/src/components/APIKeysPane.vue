<template>
  <h2>Add API Keys to use Twitter, Bing and OpenAI ChatGPT</h2>
  <el-icon style="size: 5px; vertical-align: middle; margin-bottom: 0.3em;">
    <info-filled/>
  </el-icon>
  All API keys are stored locally and transferred over encrypted HTTPS connection
  <el-link class="what-button" type="info" @click="showInfo">
    <el-icon>
      <question-filled/>
    </el-icon>
  </el-link>

  <el-form label-width="120px" style="margin-top: 2em;">
    <el-form-item label="Bing Key">
      <el-input id="bingkey" type="password" show-password style="width: 50%;" v-model="bing"
                placeholder="Enter here"/>
      <el-button class="add-button" type="primary" @click="addKey('bing')">
        Add
      </el-button>
      <el-button class="remove-button" type="danger" @click="removeKey('bing')">
        <el-icon>
          <delete/>
        </el-icon>
      </el-button>

    </el-form-item>
    <el-form-item label="Twitter Key">
      <el-input id="twitterkey" type="password" show-password style="width: 50%;" v-model="twitter"
                placeholder="Enter here"/>
      <el-button class="add-button" type="primary" @click="addKey('twitter')">
        Add
      </el-button>
      <el-button class="remove-button" type="danger" @click="removeKey('twitter')">
        <el-icon>
          <delete/>
        </el-icon>
      </el-button>
    </el-form-item>
    <el-form-item label="OpenAI Key">
      <el-input id="openaikey" type="password" show-password style="width: 50%;" v-model="openai"
                placeholder="Enter here"/>
      <el-button class="add-button" type="primary" @click="addKey('openai')">
        Add
      </el-button>
      <el-button class="remove-button" type="danger" @click="removeKey('openai')">
        <el-icon>
          <delete/>
        </el-icon>
      </el-button>
    </el-form-item>
    <el-form-item>

    </el-form-item>
  </el-form>
</template>

<script>
import {ElMessage, ElMessageBox} from 'element-plus';
import {Delete, InfoFilled, QuestionFilled} from '@element-plus/icons-vue';

export default {
  name: "APIKeysPane",
  components: {Delete, QuestionFilled, InfoFilled},
  data() {
    return {
      bing: localStorage.getItem("bingkey"),
      twitter: localStorage.getItem("twitterkey"),
      openai: localStorage.getItem("openaikey")
    }
  },

  methods: {
    addKey(keyType) {
      switch (keyType) {
        case "bing":

          if (this.bing && this.bing !== localStorage.getItem("bingkey")) {
            localStorage.setItem("bingkey", this.bing);
            ElMessage({
              message: "Bing API key added successfully",
              type: "success"
            })
          }
          break;

        case "twitter":
          if (this.twitter && this.twitter !== localStorage.getItem("twitterkey")) {
            localStorage.setItem("twitterkey", this.twitter);
            ElMessage({
              message: "Twitter API key added successfully",
              type: "success"
            })
          }
          break;
        case "openai":
          if (this.openai && this.openai !== localStorage.getItem("openaikey")) {
            localStorage.setItem("openaikey", this.openai);
            ElMessage({
              message: "OpenAI API key added successfully",
              type: "success"
            })
          }
          break;
        default:
          break;
      }

    },

    removeKey(keyType) {
      switch (keyType) {
        case "bing":
          localStorage.removeItem("bingkey");
          if (this.bing !== "") {
            ElMessage({
              message: "Bing key removed",
              type: "warning"
            });
          }
          this.bing = "";
          break;
        case "twitter":
          localStorage.removeItem("twitterkey");
          if (this.twitter !== "") {
            ElMessage({
              message: "Twitter key removed",
              type: "warning"
            });
          }
          this.twitter = "";
          break;
        case "openai":
          localStorage.removeItem("openaikey");
          if (this.openai !== "") {
            ElMessage({
              message: "OpenAI key removed",
              type: "warning"
            });
          }
          this.openai = "";
          break;
        default:
          break;
      }
    },
    showInfo() {
      const title = "What are these keys?"
      const message = "API keys are secret alphanumeric sequences provided by the API service providers for authorizing " +
          "use of their services. Find out your keys for " +
          "<a href='https://platform.openai.com/docs/api-reference/introduction' target='_blank' rel='noopener noreferrer'>OpenAI</a>" +
          ", <a href='https://learn.microsoft.com/en-us/azure/search/search-security-api-keys?tabs=portal-use%2Cportal-find%2Cportal-query' target='_blank' rel='noopener noreferrer'>Bing</a>" +
          ", <a href='https://developer.twitter.com/en/docs/twitter-api/getting-started/about-twitter-api' target='_blank' rel='noopener noreferrer' >Twitter</a>";
      ElMessageBox.alert(message, title, {
        dangerouslyUseHTMLString: true, confirmButtonText: "OK", callback: () => {
        }
      });
    }

  }
}

</script>

<style scoped>
.add-button {
  margin-left: 1rem;
}

.remove-button {
  margin-left: 1rem;
}

.what-button {
  margin-left: 0.2rem;
  vertical-align: middle;
}
</style>