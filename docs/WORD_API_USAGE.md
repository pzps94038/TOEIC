# Word Creation API Usage Examples

## API Endpoint
`POST /api/word/create-word`

## Request Format
The API follows the structure defined in `word-model.ts`:

```typescript
{
  "engWord": "string",      // 英文單字
  "twWord": "string",       // 中文單字  
  "day": number,            // 第幾天的單字
  "sentences": [            // 範例句
    {
      "engSentences": "string",  // 英文例句
      "twSentences": "string"    // 中文例句
    }
  ]
}
```

## Example Request

### Create a new TOEIC word
```bash
curl -X POST http://localhost:3000/api/word/create-word \
  -H "Content-Type: application/json" \
  -d '{
    "engWord": "achievement",
    "twWord": "成就、成績",
    "day": 5,
    "sentences": [
      {
        "engSentences": "This is a great achievement for our team.",
        "twSentences": "這對我們團隊來說是個偉大的成就。"
      },
      {
        "engSentences": "Her academic achievements are impressive.",
        "twSentences": "她的學術成就令人印象深刻。"
      }
    ]
  }'
```

### Expected Response (Success)
```json
{
  "code": "S",
  "message": "單字建立成功",
  "data": {
    "engWord": "achievement",
    "twWord": "成就、成績",
    "day": 5,
    "sentences": [
      {
        "engSentences": "This is a great achievement for our team.",
        "twSentences": "這對我們團隊來說是個偉大的成就。"
      },
      {
        "engSentences": "Her academic achievements are impressive.",
        "twSentences": "她的學術成就令人印象深刻。"
      }
    ]
  }
}
```

### Expected Response (Error)
```json
{
  "code": "F",
  "message": "英文單字為必要欄位且必須為字串",
  "data": null
}
```

## Validation Rules

The API validates the following:

1. **English Word** (`engWord`)
   - Required field
   - Must be a non-empty string

2. **Chinese Word** (`twWord`)  
   - Required field
   - Must be a non-empty string

3. **Day** (`day`)
   - Required field
   - Must be a number greater than 0

4. **Sentences** (`sentences`)
   - Required field
   - Must be an array with at least one sentence
   - Each sentence must have both `engSentences` and `twSentences`
   - Both sentence fields must be non-empty strings

## Features

- ✅ Follows the exact structure from `word-model.ts`
- ✅ Comprehensive input validation
- ✅ Service layer for business logic separation
- ✅ TypeScript interfaces for type safety
- ✅ Error handling with meaningful messages
- ✅ Ready for database integration

## Database Integration (Future)

The service layer is prepared for MySQL database integration using the migration scripts created earlier:

```sql
-- Insert word
INSERT INTO words (eng_word, tw_word, day_number, difficulty_level, word_type, created_by) 
VALUES (?, ?, ?, 'medium', 'noun', 1);

-- Insert sentences
INSERT INTO sentences (word_id, eng_sentence, tw_sentence, sentence_order, created_by) 
VALUES (?, ?, ?, ?, 1);
```