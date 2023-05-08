<template>
  <el-container style="height: calc(90vh - 40px); overflow: hidden">
    <el-main class="ner">
      <el-button
          @click="onClickNER"
          style="margin-top: 20px"
          type="primary"
          :disabled="nerLoading || newsId !== newsIdInput"
          :loading="nerLoading">
        {{ newsId === newsIdInput ? 'Run NER' : 'Reload news first' }}
      </el-button>
      <div v-if="nerOutput">
        <h4 style="text-align: left">NER Output</h4>
        <div class="sentence" v-for="(sent, sent_idx) in nerOutput">
          <div class="token" v-for="(token, token_idx) in sent">
            <span v-if="typeof token === 'string'">{{ token }}</span>
            <!-- entity -->
            <el-tooltip v-else-if="token.sent_idx !== undefined" effect="dark" placement="top"
                        :content="`Entity - ${token.type}`">
              <a :class="{highlighted: resolvedEntity && resolvedEntity.sent_idx === sent_idx && resolvedEntity.token_idx === token_idx, unresolved: unresolved(sent_idx, token_idx)}"
                 :id="`token-${sent_idx}-${token_idx}`"
                 :href="unresolved(sent_idx, token_idx) ? null : '#'"
                 v-on:click="onClickToken"
                 v-on:mouseleave="onLeaveToken"
                 v-on:mouseover="onHoverToken">
                {{ token.tokens.join(" ") }}
              </a>
            </el-tooltip>
            <!-- pro-form -->
            <el-tooltip v-else-if="token.entity !== undefined" effect="dark" placement="top"
                        :content="`Pro-form - ${token.type}`">
              <a :id="`token-${sent_idx}-${token_idx}`" :class="{unresolved: unresolved(sent_idx, token_idx)}"
                 :href="unresolved(sent_idx, token_idx) ? null : '#'"
                 v-on:click="onClickToken"
                 v-on:mouseleave="onLeaveToken"
                 v-on:mouseover="onHoverToken">
                {{ token.tokens.join(" ") }}</a>
            </el-tooltip>
          </div>
        </div>
      </div>
    </el-main>
    <div class="linker">
      <LinkerResults :newsId="newsId" :sentIdx="selectedMention.sentIdx" :tokenIdx="selectedMention.tokenIdx" :collection="collection"></LinkerResults>
    </div>
  </el-container>
</template>

<script>
import axios from "axios";
import LinkerResults from './LinkerResults.vue'


export default {
  name: "NERTab",
  emits: ["errorMsg"],
  props: ["newsId", "newsIdInput", "collection"],
  components: [LinkerResults],
  data() {
    return {
      nerLoading: false,
      nerOutput: null,
      resolvedEntity: null,
      selectedMention: {
        sentIdx: null,
        tokenIdx: null
      },
    }
  },
  watch: {
    newsId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.nerOutput = null
        this.nerLoading = false
      }
    }
  },
  methods: {
    onClickNER() {
      this.$emit("errorMsg", "")
      this.nerLoading = true
      this.nerOutput = null
      this.nerNewsId = null
      let that = this
      axios.get(
          `${this.api}/ner/${this.newsId}`,
          {params: {collection: this.collection}}
      ).then(response => {
        that.nerOutput = response.data
        that.nerNewsId = that.newsId
      }).catch(err => {
        that.$emit("errorMsg", err)
        that.nerOutput = null
      }).then( () => {
        that.nerLoading = false
      })
    },
    onHoverToken(e) {
      const parts = e.target.id.split("-")
      const sentIdx = Number(parts[1])
      const tokenIdx = Number(parts[2])
      let token = this.nerOutput[sentIdx][tokenIdx]
      if (token.entity) {
        this.resolvedEntity = token.entity
      } else if (token.resolved_entity) {
        this.resolvedEntity = token.resolved_entity
      }
    },
    onLeaveToken() {
      this.resolvedEntity = null
    },
    unresolved(sentIdx, tokenIdx) {
      let token = this.nerOutput[sentIdx][tokenIdx]
      if (token.sent_idx !== undefined && !token.proper && (token.resolved_entity === null || !token.resolved_entity.proper) ) {
        // entity, not a proper noun, not linked to a proper entity
        return true
      } else if (token.entity !== undefined && (token.entity === null || !token.entity.proper)) {
        return true
      }
      return false
    },
    onClickToken(e) {
      const parts = e.target.id.split("-")
      const sentIdx = Number(parts[1])
      const tokenIdx = Number(parts[2])
      this.selectedMention = {
        sentIdx: sentIdx,
        tokenIdx: tokenIdx
      }
    },
  }
}
</script>

<style scoped>
.ner {
  border-right: 1px solid #2c3e50;
  width: 70%;
  height: inherit;
  overflow: scroll;
}
.linker {
  position: -webkit-sticky; /* Safari & IE */
  width: 30%;
  height: inherit;
  overflow: scroll;
}
</style>
