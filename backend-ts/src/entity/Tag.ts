import { Column, Entity, ManyToMany, PrimaryGeneratedColumn } from "typeorm";
import Article from "./Article";

@Entity()
class Tag {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  tag: string;

  @ManyToMany(() => Article, (article) => article.tagList)
  articles: Article[];
}

export default Tag;
