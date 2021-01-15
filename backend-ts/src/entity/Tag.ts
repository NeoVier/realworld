import { Column, ManyToMany, PrimaryGeneratedColumn } from "typeorm";
import Article from "./Article";

class Tag {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  tag: string;

  @ManyToMany(() => Article)
  articles: Article[];
}

export default Tag;
